#!/bin/bash
#--------------------------------------------------------
#--- SCRIPT DE BACKUP INIT NET - V.1.0.1 ----------------
#--- DESENVOLVIDO POR: INIT NET SOCIEDADE EMP. LTDA -----
#--------------------------------------------------------
#--- SICRONIA OS DIRETORIOS VIA RSYNC E AVISA O ADM ----
#--- QUANDO O BABKUP ESTIVER FINALIZADO -----------------
#--------------------------------------------------------

#--------------------------------------------------------
# Inicio das configuracoes para realizar o backup -----##
#--------------------------------------------------------
datainicial=`date +%s`
RL='./rlbkdiario.txt'
RL2='./tamanho.txt'
EMAILLOG='./email.log'

#Configuracao dos Rsync
#
CAMINHO='/usr/bin'
PAR1='--progress -ravzp'
RSYNC="$CAMINHO/rsync $PAR1"
#
# fim das configuracoes do Rsync

data=`date +%d/%m/%Y-%H:%M:%S`
DISCOS=`df -ah | grep -v "none"`
#--------------------------------------------------------#
#CONFIGURACOES PARA ENVIO DO EMAIL ----------------------#
#--------------------------------------------------------#
#Remetente (OPCAO -f )
rem=""

#Destinatario (OPCAO -t)
dest=""

#Assunto do e-mail (OPCAO -u)
assok="Finalizado backup do Servidor $(hostname)"

#Servidor SMTP (OPCAO -s) example.host.com:xxx
smtp=""

#Usuario autenticador e-mail (OPCAO -xu)
user=""

#Pass autenticador e-mail (OPCAO -xp)
pas=""
#--------------------------------------------------------#
#FIM DAS CONFIGURACOES PARA ENVIO DO EMAIL --------------#
#--------------------------------------------------------#

#------------------------------------------------------#
#------------------DESTINO DO BACKUP ------------------#
#------------------------------------------------------#
#Quando for fazer copia local, colocar o nome do diretorios
#que irá armazenar o backup na linha abaixo -----------#
DESTINO='/backup'

#Quando for fazer copia remota, via ssh colocar no seguinte
#formato:host:/diretorio/destino - sem a barra no final #
#DESTINO='backup:/backup/benjamin'

#--------------------------------------------------------
# Finalizar os diretorios sem / para copiar a pasta toda-
#--------------------------------------------------------

###----------- COMECANDO AQUI A LISTA DE DIRETORIOS, UM POR LINNHA ---##
DIRETORIOS=(
/home/samba/shares/cliente
/home/samba/shares/comercial
/home/samba/shares/financeiro
/home/samba/shares/init
/home/samba/shares/srv
/home/samba/shares/teste
/home/samba/shares/utilitarios
/srv/www
/home/samba/shares/web
)
###------------ FINALIZA AQUI A LISTA DOS BACKUPS ---------------- #####

echo  "#-------------------------------------------------#" > $RL
echo  "#---- INICIANDO BACKUP DO DIA $data ---#" >> $RL
echo  "#-------------------------------------------------#" >> $RL

for dir in "${DIRETORIOS[@]}"; do
		echo "$data" >> "$dir/data.txt"

		#quando em teste, deixar essa linha livre e comentar a de baixo
		#echo "$dir" $DESTINO

		#Quando em producao deixar essa linha livre e comentar a de cima
		$RSYNC "$dir" $DESTINO >> $RL
done

#for dirs in "${DIRETORIOS[@]}"; do
#echo  "#-------------------------------------------------#" > $EMAILLOG
#echo  "#------------- TAMANHO DOS DIRETORIOS ------------#" >> $EMAILLOG
#echo  "#-------------------------------------------------#" >> $EMAILLOG
#du -sh "$dirs" >> $RL2
#done
datafinal=`date +%s`
soma=`expr $datafinal - $datainicial`
resultado=`expr 10800 + $soma`
tempo=`date -d @$resultado +%H:%M:%S`

(
cat <<EOF

  INFORMACOES GERAIS
------------------------------------------------------------------------

Host:   $(hostname)
Inicio: ${data}
Fim:    $(date +%d/%m/%Y-%H:%M:%S)
Gasto:	${tempo}
Uptime: $(uptime)

-------------------------------------------------------------------------
   TAMANHO DOS DIRETORIOS DE BACKUP
-------------------- ----------------------------------------------------
$(for dirs in "${DIRETORIOS[@]}";
do
du -sh $dirs
done)
-------------------------------------------------------------------------
   ESPACO EM DISCO
-------------------------------------------------------------------------
${DISCOS}
------------------------------------------------------------------------
Relatorio dos arquivos copiados em anexo.

EOF
) > $EMAILLOG 

/usr/bin/perl /bin/sendEmail.pl -f $rem -t $dest -u "$assok" -m -o message-file=$EMAILLOG -a "$RL" -l "status_email.log" -s $smtp -xu $user -xp $pas -o tls=no;

#poweroff

