#!/bin/sh
#-----------------------------------------------
#SCRIPT PARA ENVIO DIARIO DO TESTE DE VELOCIDADE
# v. 1.0 - 29-02-2024
#-----------------------------------------------
#Variaveis
log_simple="./speedtest.log"
log_verbose="./speedtest_completo.log"

now="$(date +'%d/%m/%Y %T')"
#----------------------------------------------
#INTERFACES
#----------------------------------------------
INTERFACE01="em0"
SOURCE01=$(/sbin/ifconfig $INTERFACE01 | /usr/bin/grep -w inet | /usr/bin/sed -e 's/^[[:space:]]*//' | /usr/bin/cut -d ' ' -f2)
link1="VELOCIDADE LINK DA CLARO (400MB)"
#
#
INTERFACE02="em2"
SOURCE02=$(/sbin/ifconfig $INTERFACE02 | /usr/bin/grep -w inet | /usr/bin/sed -e 's/^[[:space:]]*//' | /usr/bin/cut -d ' ' -f2)
link2="VELOCIDADE LINK DA TELIUM (10MB)"
#--------------------------------------------------------#
#CONFIGURACOES PARA ENVIO DO EMAIL ----------------------#
#--------------------------------------------------------#
#Remetente (OPCAO -f )
rem="quem@envia.com.br"

#Destinatario (OPCAO -t)
dest="email@destinatario.com.br"

#Assunto do e-mail (OPCAO -u)
assok="Teste de velocidade diario -  $(hostname)"

#Servidor SMTP (OPCAO -s) example.host.com:xxx
smtp="smtp.servidor.com:587"

#Usuario autenticador e-mail (OPCAO -xu)
user="email@autenticacao"

#Pass autenticador e-mail (OPCAO -xp)
pas="password"
#--------------------------------------------------------#
#FIM DAS CONFIGURACOES PARA ENVIO DO EMAIL --------------#
#--------------------------------------------------------#
#simple speed test
#printf "$now\n" > "$log_simple"
#speedtest-cli --simple >> "$log_simple"
#printf '\n' >> "$log_simple"

#-------------------------------------------------------
#TESTE COMPLETO PARA ENVIO
#-------------------------------------------------------
printf "Teste do dia: $now\n" > "$log_verbose"
printf "$link1 - $SOURCE01" >> "$log_verbose"
printf '\n' >> "$log_verbose"
speedtest-cli --source $SOURCE01 >> "$log_verbose"
printf '\n' >> "$log_verbose"
printf "$link2 - $SOURCE02" >> "$log_verbose"
printf '\n' >> "$log_verbose"
speedtest-cli --source $SOURCE02 >> "$log_verbose"
printf '\n' >> "$log_verbose"

/usr/local/bin/perl ./sendEmail.pl -f $rem -t $dest -u "$assok" -m -o message-file=$log_verbose -a "$RL" -l "status_email.log" -s $smtp -xu $user -xp $pas -o tls=no;
