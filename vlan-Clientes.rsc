##Script criado para adicionar a Vlan de clientes#
#OBS: VERIFICAR SE OS IP'S APRESENTADOS AQUI JÁ NÃO ESTÃO EM USO#


#PASSO 01 - Criacao da vlan na interface Bridge e adicao na lista "LAN_GUEST"#

/interface vlan add comment="MC6def :: Rede virtual local para isolamento dos clientes/visitantes." interface=bridgeLan name=vlan90_InternetVisitantes vlan-id=90
/interface list add comment="MC6def :: Interfaces da rede interna/privada para visitantes." name=LAN_GUEST
/interface list member add comment="MC6def :: Rede interna/privada de visitantes." interface=vlan90_InternetVisitantes list=LAN_GUEST

#PASSO 02 - Adiciona endereco IP na vlan#

/ip address
add address=10.10.0.1/22 comment="MC6def :: Endereco IP da Rede Local/Interna \
    de Internet para os visitantes." interface=vlan90_InternetVisitantes \
    network=10.10.0.0

#PASSO 03 - Cria o pool DHCP para entrega de IP#

/ip pool add comment="MC6def :: Fila de enderecos IP que podem ser entregues para a rede de internet para os visitantes." name=poolDhcpRedeInternetVisitantes ranges=10.10.0.2-10.10.3.254

#PASSO 04 - Cria o servidor DHCP#

/ip dhcp-server add address-pool=poolDhcpRedeInternetVisitantes disabled=no interface=vlan90_InternetVisitantes lease-time=4h name=dhcpRedeInternetVisitantes comment="MC6def :: Servidor DHCP para rede visitantes"
/ip dhcp-server network add address=10.10.0.0/22 comment="MC6def :: Definicoes de rede para serem entregues para a rede local de internet para os visitantes." dns-server=10.10.0.1 domain=internet.visitantes gateway=10.10.0.1 netmask=22

#PASSO 05 - Adiciona regras de firewall para isolamento da rede#

/ip firewall filter
/ip firewall filter add action=accept chain=input comment="MC6def :: Permite responder ao ping em todas as redes privadas/internas de internet para visitantes (ICMP ECHO REQUEST)" icmp-options=8:0 in-interface-list=LAN_GUEST protocol=icmp
/ip firewall filter add action=accept chain=input comment="MC6def :: Permite requisicoes de DHCP nas redes privadas/internas de internet para visitantes (67-68/UDP)" dst-port=67-68 in-interface-list=LAN_GUEST protocol=udp
/ip firewall filter add action=drop chain=input comment="MC6def :: Bloqueia qualquer requisicao de entrada das redes privadas/internas de visitantes" connection-state=invalid,untracked in-interface-list=LAN_GUEST
/ip firewall filter add action=drop chain=forward comment="MC6def :: Bloqueia qualquer encaminhamento para as redes privadas/internas de internet para visitantes" connection-state=invalid,new,untracked disabled=yes in-interface-list=LAN_GUEST