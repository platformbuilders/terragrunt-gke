# Terraform GCP Stacks com Terragrunt

Este repositório contém a configuração de infraestrutura como código (IaC) usando Terragrunt para gerenciar recursos do Google Cloud Platform (GCP). Ele é projetado para trabalhar em conjunto com um repositório de módulos Terraform reutilizáveis.

## Estrutura do Repositório

```
.
├── terragrunt.hcl                     # Configuração raiz do Terragrunt
├── _envcommon/                        # Configurações comuns entre ambientes
│   ├── gke-cluster.hcl                # Configuração comum para GKE
│   └── gke-nodepool.hcl               # Configuração comum para node pools
└── environments/                      # Ambientes
    ├── dev/
    │   ├── terragrunt.hcl             # Configuração específica do ambiente dev
    │   ├── gke-cluster/
    │   │   └── terragrunt.hcl
    │   └── gke-nodepool/
    │       └── terragrunt.hcl
    └── prod/
        ├── terragrunt.hcl             # Configuração específica do ambiente prod
        ├── gke-cluster/
        │   └── terragrunt.hcl
        └── gke-nodepool/
            └── terragrunt.hcl
```

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) (versão >= 1.0.0)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (versão >= 0.38.0)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Acesso ao repositório de módulos Terraform

## Configuração Inicial

1. **Autenticação GCP**:
   ```bash
   gcloud auth application-default login
   ```

2. **Configuração do Remote State**:
   Verifique se o bucket GCS para armazenar o estado do Terraform existe. Caso contrário, crie:
   ```bash
   gsutil mb -l us-central1 gs://seu-projeto-tfstate/
   ```

3. **Configuração do Terragrunt**:
   Atualize o arquivo `terragrunt.hcl` na raiz do repositório com os detalhes do seu projeto GCP e do repositório de módulos.

## Uso

### Comandos Básicos

Para aplicar toda a infraestrutura em um ambiente:

```bash
cd environments/dev
terragrunt run-all apply
```

Para aplicar somente um componente específico:

```bash
cd environments/dev/gke-cluster
terragrunt apply
```

Para destruir toda a infraestrutura em um ambiente:

```bash
cd environments/dev
terragrunt run-all destroy
```

### Variáveis Locais

O Terragrunt permite definir variáveis locais que podem ser reutilizadas em diferentes componentes. Aqui estão alguns exemplos:

#### Exemplo 1: Variáveis locais no terragrunt.hcl raiz

```hcl
# terragrunt.hcl
locals {
  # Variáveis do projeto
  project_id        = "meu-projeto-gcp"
  region            = "us-central1"
  default_location  = "us-central1-a"
  
  # Variáveis de rede
  vpc_name          = "vpc-shared"
  subnet_name       = "subnet-gke"
  
  # Metadados comuns
  tags = {
    owner       = "devops-team"
    managed_by  = "terragrunt"
    source_repo = "github.com/sua-empresa/infra-stacks"
  }
  
  # Repositório de módulos
  module_repo_url   = "git@github.com:sua-empresa/terraform-modules-gcp.git"
  module_version    = "v1.0.0"
  
  # Configurações de remote state
  state_bucket      = "seu-projeto-tfstate"
  state_location    = "us-central1"
}
```

#### Exemplo 2: Variáveis locais em um ambiente específico

```hcl
# environments/dev/terragrunt.hcl
locals {
  # Carrega as variáveis do root
  root_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Variáveis específicas do ambiente
  environment       = "dev"
  project_id        = "meu-projeto-dev"
  gke_node_count    = 2
  max_node_count    = 5
  machine_type      = "e2-standard-2"
  
  # CIDRs para o ambiente de desenvolvimento
  pod_cidr          = "10.0.0.0/14"
  service_cidr      = "10.4.0.0/20"
  master_cidr       = "172.16.0.0/28"
  
  # Merging tags
  tags = merge(
    local.root_vars.locals.tags,
    {
      environment = local.environment
    }
  )
}
```

#### Exemplo 3: Variáveis locais em um componente específico

```hcl
# environments/dev/gke-cluster/terragrunt.hcl
locals {
  # Carrega as variáveis do ambiente
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Variáveis específicas do componente
  cluster_name      = "gke-${local.env_vars.locals.environment}-cluster"
  release_channel   = "STABLE"
  nodes_locations   = ["us-central1-a", "us-central1-b", "us-central1-c"]
  
  # Etiquetas específicas para este cluster
  cluster_labels = merge(
    local.env_vars.locals.tags,
    {
      component = "gke"
      purpose   = "kubernetes-workloads"
    }
  )
}
```

### Exemplos de Uso das Variáveis Locais

#### Exemplo de uso em inputs

```hcl
# environments/dev/gke-cluster/terragrunt.hcl
inputs = {
  project_id        = local.env_vars.locals.project_id
  cluster_name      = local.cluster_name
  master_location   = local.env_vars.locals.region
  nodes_location    = local.nodes_locations
  
  vpc_id            = "projects/${local.env_vars.locals.project_id}/global/networks/${local.env_vars.locals.vpc_name}"
  subnet_id         = "projects/${local.env_vars.locals.project_id}/regions/${local.env_vars.locals.region}/subnetworks/${local.env_vars.locals.subnet_name}"
  
  # Outras configurações usando variáveis locais
  master_cidr       = local.env_vars.locals.master_cidr
  pods_cidr         = local.env_vars.locals.pod_cidr
  services_cidr     = local.env_vars.locals.service_cidr
  
  labels            = local.cluster_labels
}
```

## Ambientes Disponíveis

### Desenvolvimento (dev)

Ambiente para desenvolvimento e testes, com recursos menores e menos redundância.

```bash
cd environments/dev
terragrunt run-all apply
```

### Produção (prod)

Ambiente de produção com alta disponibilidade e configurações robustas.

```bash
cd environments/prod
terragrunt run-all apply
```

## Manutenção e Boas Práticas

### Versionamento dos Módulos

Os módulos são referenciados com uma versão específica:

```hcl
terraform {
  source = "${local.module_repo_url}//gke?ref=${local.module_version}"
}
```

Recomenda-se atualizar as versões dos módulos de forma controlada e após testes.

### Gerenciamento de Secrets

Nunca armazene secrets diretamente nos arquivos Terragrunt. Use o Google Secret Manager ou outro gerenciador de secrets.

Para usar secrets em seu código:

```hcl
data "google_secret_manager_secret_version" "my_secret" {
  project = local.project_id
  secret  = "my-secret-name"
}

locals {
  secret_value = data.google_secret_manager_secret_version.my_secret.secret_data
}
```

### Organização de Ambientes Múltiplos

Para adicionar um novo ambiente (como staging):

1. Crie um novo diretório em `environments/`
2. Copie a estrutura de `dev/` para o novo diretório
3. Ajuste as variáveis conforme necessário

```bash
mkdir -p environments/staging/gke-cluster
mkdir -p environments/staging/gke-nodepool
cp environments/dev/terragrunt.hcl environments/staging/
cp environments/dev/gke-cluster/terragrunt.hcl environments/staging/gke-cluster/
cp environments/dev/gke-nodepool/terragrunt.hcl environments/staging/gke-nodepool/
```

### Comando de Validação

Para validar toda a configuração:

```bash
cd environments/dev
terragrunt run-all validate
```

## Troubleshooting

### Erros Comuns

1. **Error: Failed to load state**

   Verifique se o bucket de estado existe e se você tem permissões adequadas:
   ```bash
   gsutil ls -la gs://seu-projeto-tfstate/
   ```

2. **Error: Failed to get existing workspaces**

   Pode ser um problema de autenticação:
   ```bash
   gcloud auth application-default login
   ```

3. **Error: Module not found**

   Verifique se o repositório de módulos está acessível e se a referência está correta:
   ```hcl
   terraform {
     source = "${local.module_repo_url}//gke?ref=${local.module_version}"
   }
   ```

## Contribuindo

1. Crie uma branch para sua feature: `git checkout -b feature/nova-feature`
2. Faça commit das suas alterações: `git commit -am 'Adiciona nova feature'`
3. Faça push para a branch: `git push origin feature/nova-feature`
4. Abra um Pull Request

## Recursos Adicionais

- [Documentação do Terragrunt](https://terragrunt.gruntwork.io/docs/)
- [Documentação do Terraform para GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Melhores Práticas Terraform](https://cloud.google.com/docs/terraform/best-practices-for-terraform)