# Infrastructure Azure (Terraform)

Infrastructure du pipeline NYC Taxi, décrite en Terraform (provider `azurerm` 3.x) et découpée en modules.

## Ce qui est déployé

| Ressource | Fichier / module | Rôle |
|---|---|---|
| Groupe de ressources (existant) | `main.tf` (data source) | Fourni par la formation : lu, jamais créé ni détruit |
| Suffixe aléatoire | `modules/naming` | Rend uniques les noms globaux (Storage, Cosmos DB, ACR) |
| Storage Account + Blob Container | `modules/storage` | Data lake des fichiers Parquet téléchargés |
| Cosmos DB (compte, base, container) | `modules/cosmos` | Base du projet, 400 RU/s partagés au niveau de la base |
| Azure Container Registry (Basic) | `container_registry.tf` | Registry privé de l'image `nyc-taxi-pipeline` |
| Container Apps (environnement + app) | `modules/containerapp` | Exécute le pipeline ; secrets pour la connexion Storage, le mot de passe PostgreSQL et l'ACR |

Toutes les ressources portent les tags de `var.tags` (Project, Owner, Environment, ManagedBy).

## Déployer

Prérequis : Terraform >= 1.0, Azure CLI, Docker.

```bash
az login
cd terraform
cp terraform.tfvars.example terraform.tfvars   # puis remplir ; ce fichier n'est jamais versionné
terraform init
terraform plan
terraform apply
```

Puis construire et pousser l'image du pipeline dans l'ACR créé :

```bash
ACR=$(terraform output -raw acr_login_server)
az acr login --name "${ACR%%.*}"
docker build -t "$ACR/nyc-taxi-pipeline:latest" ..
docker push "$ACR/nyc-taxi-pipeline:latest"
```

Supprimer l'infrastructure (le groupe de ressources, lu en data source, est conservé) : `terraform destroy`.

## Variables principales

| Variable | Défaut | Description |
|---|---|---|
| `project_name`, `environment` | — | Entrent dans le nom des ressources (`environment` : dev, test ou prod) |
| `resource_group_name` | `otymoshenkoRG` | Groupe de ressources existant |
| `location` | `francecentral` | Région |
| `start_date`, `end_date` | — | Mois ingérés (YYYY-MM), passés au pipeline |
| `container_apps_cpu`, `container_apps_memory` | `0.5`, `1Gi` | Ressources du container |
| `container_apps_min_replicas` | `0` | 0 = aucun coût quand le pipeline ne tourne pas |
| `throughput` | `400` | RU/s de Cosmos DB (minimum) |
| `postgres_password` | — | Secret ; dans `terraform.tfvars` ou `TF_VAR_postgres_password` |

Sorties : `terraform output` (Storage, Cosmos DB, ACR, Container App).

## Variables d'environnement du pipeline

La Container App fournit au code Python : `AZURE_STORAGE_CONNECTION_STRING` (secret), `AZURE_CONTAINER_NAME`, `START_DATE`, `END_DATE`, `POSTGRES_PASSWORD` (secret), et les entrées de `env_vars` (`POSTGRES_HOST`, `POSTGRES_DB`...).

## Coûts

Storage LRS, ACR Basic, Cosmos DB au minimum (400 RU/s partagés par la base au lieu d'un débit par container), Container App à 0 réplica au repos. Penser à `terraform destroy` après usage.

## Sécurité

Jamais versionnés (`.gitignore`) : `terraform.tfvars`, `*.tfstate*` (le state contient les clés en clair), `tf.log`, `.terraform/`. Les valeurs sensibles sont marquées `sensitive` et passent à la Container App par des secrets.

## Limites connues

- Le brief demande **Cosmos DB for PostgreSQL** ; ce code provisionne Cosmos DB **API NoSQL**. Le pipeline écrit en PostgreSQL (`utils/database.py`) : il faut une ressource `azurerm_cosmosdb_postgresql_cluster` et passer son hôte dans `env_vars`.
- Pas encore de **Log Analytics** : l'environnement Container Apps n'est relié à aucun espace de travail, les logs ne sont pas conservés.
- L'ACR utilise le compte admin ; une identité managée avec le rôle `AcrPull` serait plus sûre.
- Le pipeline est un traitement batch : un **Container App Job** conviendrait mieux qu'une Container App.
