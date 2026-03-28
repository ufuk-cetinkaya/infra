# infra (Infrastructure as Code & GitOps)

Bu depo, e-belge ekosisteminin Azure üzerindeki tüm altyapısını Terraform ile yöneten ve uygulama dağıtımlarını ArgoCD ile otomatize eden ana altyapı merkezidir.

🏗 Altyapı Bileşenleri (Terraform)
Azure üzerindeki kaynaklar Terraform kullanılarak DRY prensiplerine uygun şekilde yönetilmektedir.

AKS (Azure Kubernetes Service): Uygulamaların üzerinde koştuğu ana cluster.

Azure SQL Server: Sistem verilerini tutan yönetilen veritabanı sunucusu.

Azure Key Vault: Hassas verilerin (DB connection strings, API keys vb.) güvenli depolanması.

Backend: tfstate dosyaları Azure Blob Storage üzerinde merkezi ve güvenli bir şekilde saklanır.

🚀 Bootstrap & Cluster Kurulumu
Yeni bir cluster kurulumunda bootstrap.sh betiği çalıştırılarak aşağıdaki kritik bileşenler Helm ile otomatik olarak yüklenir:

ArgoCD: Sürekli dağıtım (CD) ve GitOps süreçleri için.

External Secrets Operator (ESO): Azure Key Vault'taki secretları Kubernetes Secret'larına güvenli bir şekilde senkronize etmek için.

Nginx Ingress Controller: Dış dünyadan gelen istekleri servislere yönlendirmek için.

Initial Manifests: Temel namespace ve yapılandırma dosyalarının otomatik uygulanması.

🔄 GitOps & Deployment Akışı
Sistem, tam otomatik bir Image Update döngüsüne sahiptir:

Image Updater: ArgoCD Image Updater, GHCR (GitHub Container Registry) üzerindeki imajları izler.

Auto-Update: Yeni bir imaj tespit edildiğinde, bu depodaki ilgili Kubernetes manifestini (image tag) otomatik olarak günceller.

Sync: ArgoCD, manifestteki değişikliği algılayarak cluster üzerindeki uygulamayı yeni versiyona senkronize eder.

📁 Klasör Yapısı
/terraform: Azure kaynak tanımları (.tf dosyaları).

/argocd: Argocd k8s manifestleri.

/apps: signer-ws, gib-user-service ve ebelge-gib-integration repolarındaki servislerin k8s manifestleri.

🛠 Kullanım
Altyapıyı Oluşturun:

Bash
cd terraform
terraform init
terraform apply
Cluster'ı Hazırlayın:

Bash
./bootstrap.sh
