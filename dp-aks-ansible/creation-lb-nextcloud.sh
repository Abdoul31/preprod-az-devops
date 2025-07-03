RG_NAME="devops-deploy-vm-rg"
LOCATION="francecentral"
LB_NAME="aks-standard-lb"
VNET_NAME="aks-vnet"
SUBNET_NAME="aks-subnet"
PUBLIC_IP_NAME="aks-lb-pip"
BACKEND_POOL="aks-backendpool"

#creation IP Publique PIP
az network public-ip create \
  --resource-group $RG_NAME \
  --name $PUBLIC_IP_NAME \
  --sku Standard \
  --allocation-method Static \
  --location $LOCATION

  #creation du load balancer
az network lb create \
  --resource-group $RG_NAME \
  --name $LB_NAME \
  --sku Standard \
  --location $LOCATION \
  --frontend-ip-name aksFrontendConfig \
  --backend-pool-name $BACKEND_POOL \
  --public-ip-address $PUBLIC_IP_NAME

  #Ajout d'une regleload balancer http
az network lb rule create \
  --resource-group $RG_NAME \
  --lb-name $LB_NAME \
  --name HTTPRule \
  --protocol Tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name aksFrontendConfig \
  --backend-pool-name $BACKEND_POOL \
  --probe-name httpProbe

  #Ajout dune sonde HTTP
az network lb probe create \
  --resource-group $RG_NAME \
  --lb-name $LB_NAME \
  --name httpProbe \
  --protocol Http \
  --port 80 \
  --path /