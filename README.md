# Desafio-Sensedia
Projeto desafio sensedia, provisionar estrutura para web server em nuvem.

Este projeto tem por finalidade fornecer a automação necessária para execução de um script hospedado em um webserver em nuvem, conforme descrito no arquivo da pasta desafio. 

As tecnologias base utilizadas foram: Terraform, AWS ECS + ERS, Docker e Shell script em conjunto para prover toda a criação do acesso ao script de maneira automatizada.

Devido ao tempo e falta de conhecimento em determinados tópicos não foi possível concluir o desenvolvimento total da automação do container via terraform, contudo abaixo irei detalhar todo o funcionamento do container em execução diretamente na instância EC2, e também o código construído em terraform para criação da automação.


Execução do container na instância EC2:

Requisitos

Antes de começar, certifique-se de ter o seguinte:

Conta AWS ativa;

Instância EC2 com docker, terraform e AWS CLI instalados;

Faça o clone deste repositório na instância EC2.

Crie um diretório chamado "Dockerfile" e dentro dele crie um outro diretório chamado "ubuntu", dentro dele copie os arquivos abaixo: 
1. Arquivo script-desafio.sh localizado na pasta “script”, ele será responsável pela logica do desafio;
2. Arquivo Dockerfile localizado na pasta ”docker-file”, ele será responsável pelos parâmetros da imagem docker customizada;
3. Arquivo challenger-2023 localizado na pasta "Desafio", responsável pelos dados do desafio;

Configuração do container:

Execute o comando "docker build -t (nome da imagem) . " para construir a imagem customizada que será utilizada no desafio;

Em seguida execute o comando "docker run -it (nome da imagem)" para executar o seu container.

Executando o script através do container criado:

Assim que o container for executado será exibido um prompt solicitando as informações do nome do cliente (Ex: Cliente1), tipo de arquivo (Ex: Calls ou Metrics) e data solicitada (Ex: 2022_11_01):

Prompt:

Digite o nome do cliente que deseja filtrar:

XXXXXXX

Digite o tipo de arquivo que deseja filtrar (Calls ou Metrics):

XXXXXXX

Digite a data solicitada:

XXXXXXX

Logo após inserir as informações, o script irá filtrar todos os arquivos para a data, tipo e nome do cliente solicitado e em seguida deletar todos os arquivos do cliente selecionado dentro da pasta challenge-2023.

Exemplo:

![image](https://user-images.githubusercontent.com/107517282/233273949-8d49c62d-021b-4b83-9bfd-f5558ade4965.png)


Provisionamento dos recursos via Terraform e ECS

1. Acessar a conta AWS e criar um repositorio para armazenar o docker-file no serviço ECR, Amazon ECR > Repositórios > Criar repositório:

![image](https://user-images.githubusercontent.com/107517282/233275715-fd8df1c9-ba73-4468-9a31-45928f4bde24.png)

2. Em seguida realize o "push" da imagem através do AWS CLI para a mesma ficar registrada no ECR, para isso utilize os seguindos comandos:

"docker tag nome_imagem:latest AWS_ID.dkr.ecr.us-east-1.amazonaws.com/nome_imagem:latest"

"docker push AWS_ID.dkr.ecr.us-east-1.amazonaws.com/nome_imagem:latest" 

3. Clone o arquivo localizado na pasta "terraform" e preencha com os dados necessários para provisionar os recursos.

task > main.tf = Arquivo responsável pela criação da task definition

resource "aws_ecs_task_definition" "nome_task" {
  
  family                   = "nome-task"
  
  container_definitions    = jsonencode([{
  
    name  = "nome_container"
    
    image = "AWS_ID.dkr.ecr.us-east-1.amazonaws.com/nome_imagem:latest"
    
    command = ["/bin/bash","script-desafio.sh"]
  
  }])
  
  execution_role_arn       = "arn:aws:iam::AWS_ID:role/"
  
  task_role_arn            = "arn:aws:iam::AWS_ID:role/"
  
  network_mode             = "awsvpc"
  
  requires_compatibilities = ["FARGATE"]

  memory = 512
  
  cpu    = 256
}

cluster > main.tf = Arquivo responsável pela criação do cluster ECS

resource "aws_ecs_cluster" "nome_cluster" {
  
  name = "nome_cluster"

}

Após ajustar a stack é necessario executar os comandos abaixo nos diretorios que contem as configurações dos recursos (main.tf):

"terraform init"

"terraform plan"

"terraform apply"

Por fim acesse a console e valide a criação dos recursos.
