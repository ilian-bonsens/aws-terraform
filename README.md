# aws-terraform

Ce projet a pour but de déployer une infrastructure cloud sur AWS en utilisant Terraform. À l'origine, cette infrastructure a été configurée manuellement via la console AWS. Cependant, ce projet a été réécrit pour automatiser la création et la gestion des ressources à l'aide de Terraform, afin de faciliter le déploiement, la gestion des versions et les bonnes pratiques d'infrastructure as code (IaC).

Objectifs du projet

Le projet permet de créer et de gérer une infrastructure AWS incluant :

- Deux instances EC2 sur lesquelles un serveur Apache est installé pour héberger une page web.
- Un Load Balancer (ALB) qui gère le trafic entrant et assure la haute disponibilité des instances.
- Mise en place d'un certificat SSL pour sécuriser les connexions HTTPS.

Le but est de reproduire une infrastructure déjà manuellement configurée, mais désormais entièrement automatisée grâce à Terraform.

Description de l'Infrastructure

L'infrastructure déployée comprend les éléments suivants :

- Instances EC2 : Deux instances Amazon Linux 2023 sont créées, chacune exécutant Apache pour héberger une page web.
- Application Load Balancer (ALB) : Un Load Balancer qui répartit le trafic entre les deux instances EC2 et qui utilise SSL pour sécuriser les connexions.
- Sécurisation du trafic : Le trafic HTTP est redirigé vers HTTPS et le certificat SSL est géré via AWS ACM (AWS Certificate Manager).