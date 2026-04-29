cd /
cd C:\PetShop\Bin\
SrvPetShop.exe -debug /install
sc config SrvPetShopApp binpath="C:\PetShop\Bin\SrvPetShop.exe -debug"
sc description SrvPetShopApp "PetShop - Servico de Integracao APP"
pause