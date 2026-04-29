object SrvPetShopApp: TSrvPetShopApp
  OldCreateOrder = False
  DisplayName = 'PetShop - Servico de Integracao APP'
  Interactive = True
  StartType = stManual
  OnExecute = ServiceExecute
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
