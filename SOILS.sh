#!/bin/bash

DB_USER="sistema"
DB_PASS="pimIII"
DB_HOST="localhost"
DB_NAME="seedsoil"


function query() {
	echo
	echo ">---------------------------| CONSULTA INICIO |-------------------------------->"
	echo
	mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -e "$*"
	echo
	echo "<-----------------------------| CONSULTA FIM |---------------------------------<"
	echo
}

function banner() {
	clear;
	echo -e "+=======================================================================+"
	echo -e "|\t\t\t\tSOILS\t\t\t\t\t|"
	echo -e "+=======================================================================+"
	echo -e "|\tMenu $MENU\t\t\t\t\t\t\t|"
	echo -e "+=======================================================================+"
}


function opcao() {
	unset OPCAO
	echo 
	echo -en "\t[ ] OPCAO: "
	read OPCAO
}

function fim() {
	echo -en "[!] Pressione enter para continuar. "
	read
}

function escolha() {
	case "$@" in
		1) menu_consulta ;;
		2) menu_registro ;;
		"consulta 1") query "SELECT id,endereco,responsavel,telefone FROM pontos_coleta";;
		"consulta 2") query "SELECT * FROM containers";;
		"consulta 3") query "SELECT * FROM containers WHERE status = 'DISPONIVEL'";;
		"consulta 4") query "SELECT c.id,c.codigo,c.status, p.endereco,p.responsavel,p.telefone from containers c, pontos_coleta p WHERE c.id = p.container and status = 'ALOCADO';";;
		"consulta 5") query "SELECT c.id,c.codigo,c.status, p.endereco,p.responsavel,p.telefone from containers c, pontos_coleta p WHERE c.id = p.container and status = 'COLETAR';";;
		"registro 1") cadastrar_ponto_coleta;;
		"registro 2") cadastrar_container;;
		"registro 3") TIPO=PONTO; deletar_registro;;
		"registro 4") TIPO=CONTAINER; deletar_registro;;
		"registro 5") TIPO=PONTO; atualizar_registro;;
		"registro 6") TIPO=CONTAINER; atualizar_registro;;
		"cadastro 1") query "INSERT INTO pontos_coleta (endereco, responsavel, telefone) VALUES ('$ENDERECO','$RESPONSAVEL','$TELEFONE');" > /dev/null ;;
		"cadastro 2") query "INSERT INTO containers (codigo,status) VALUES ('$CODIGO','DISPONIVEL');" > /dev/null ;;
		"cadastro 3") query "UPDATE pontos_coleta SET endereco = '$ENDERECO', responsavel = '$RESPONSAVEL', telefone = '$TELEFONE' WHERE id = $ID;" > /dev/null ;;
		"cadastro 4") query "UPDATE containers SET status = 'DISPONIVEL' WHERE id = $ID;" > /dev/null; query "UPDATE pontos_coleta SET container = NULL WHERE id = $ID_PONTO;" > /dev/null ;;
		"cadastro 5") query "UPDATE containers SET status = 'ALOCADO' WHERE id = $ID;" > /dev/null; query "UPDATE pontos_coleta SET container = '$ID' WHERE id = $ID_PONTO;" > /dev/null ;;
		"cadastro 6") query "UPDATE containers SET status = 'COLETAR' WHERE id = $ID;" > /dev/null ;;
		*) echo -e "\n[!] Opcao invalida! ";;
	esac
}

function confirma() {
	unset CONFIRMA
	while [ -z $CONFIRMA ]; do
		echo 
		echo -en "[?] Confirmar registro? [ S | N ] "
		read CONFIRMA
		case "$CONFIRMA" in
			n|N) echo; echo "[!] Registro cancelado!" ;;
			s|S) echo; echo "[!] Registro executado!";;
			*) echo -e "[!] Opcao invalida!"; unset CONFIRMA;;
	   	esac
	done

}

function status_container() {
	unset STATUS
	while [ -z $STATUS ]; do
		echo 
		echo -en "\t[ ] Novo Status: "
		read STATUS
		case "$STATUS" in
			0) STATUS=DISPONIVEL;;
			1) STATUS=ALOCADO;;
			2) STATUS=COLETAR;;
			*) echo; echo -e "[!] Opcao invalida!"; fim; unset STATUS;;
	   	esac
	done

}

function verifica_container() {

	if [ "$STATUS" == "$STATUS_ATUAL" ]; then
		echo
		echo -e "[!] Status ATUAL inalterado!"
		return 1;
	fi

	if [ "$STATUS" == "COLETAR" ]; then
		query "SELECT * FROM pontos_coleta WHERE container = $ID;" > /tmp/ponto-container_$ID
		if ! grep . /tmp/ponto-container_$ID | grep -v CONSULTA > /dev/null; then
			echo
			echo -e "[!] Impossivel COLETAR, container DISPONIVEL!"
			return 1;

		elif [ "$STATUS" == "ALOCADO" ]; then
			escolha "cadastro 5";
		fi

	fi

	if [ "$STATUS" == "ALOCADO" ]; then
		echo
		echo -e "[!] Status ALOCADO requer ID PONTO COLETA!"
		fim;
		unset ID_PONTO
		if [ -z $ID_PONTO ]; then
			echo
			echo -en "\t> ID PONTO COLETA: "
			read ID_PONTO
			case "$ID_PONTO" in
				*[0-9]*) ;;
				*) echo; echo "[!] ID Invalido!"; unset ID_PONTO; return 1; fim;;
			esac
		fi
		query "SELECT * FROM pontos_coleta WHERE id = $ID_PONTO \G;" > /tmp/ponto_coleta_$ID_PONTO;
		if ! grep . /tmp/ponto_coleta_$ID_PONTO | grep -v CONSULTA > /dev/null; then
			echo
			echo "[!] Registro nao encontrado";
			return 1;
		else
			PONTO_COLETA=$(awk -F: '/endereco/ {print $2}' /tmp/ponto_coleta_$ID_PONTO | sed 's/^ //g')
			PONTO_RESPONSAVEL=$(awk -F: '/responsavel/ {print $2}' /tmp/ponto_coleta_$ID_PONTO | sed 's/^ //g')
			PONTO_TELEFONE=$(awk -F: '/telefone/ {print $2}' /tmp/ponto_coleta_$ID_PONTO | sed 's/^ //g')
			return;
		fi
		#return;
	fi

	if [ "$STATUS" == "DISPONIVEL" ] && [ "$STATUS_ATUAL" == "ALOCADO" ]; then
		echo
		echo "[!] Container ALOCADO, necessario COLETAR!";
		return 1;
	fi

	if [ "$STATUS" == "DISPONIVEL" ]; then
		unset PONTO_COLETA PONTO_RESPONSAVEL PONTO_TELEFONE
	fi

}

function menu_principal() {
	MENU="PRINCIPAL"
	banner;
	echo
	echo -e "\t+-----------------------+"
	echo -e "\t| OPCOES\t\t|"
	echo -e "\t+-----------------------+"
	echo
	echo -e "\t> [1] - Menu CONSULTA"
	echo -e "\t> [2] - Menu REGISTRO"
	echo;echo
	echo -e "\t--------------------------"
	echo -e "\t< [0] - SAIR do sistema"
	echo -e "\t__________________________"
	echo -e "\t[Shift+PgUp] - Subir Tela"
	echo -e "\t[Shift+PgDn] - Descer Tela"
	opcao;
	if [ "$OPCAO" == 0 ]; then
		rm -f /tmp/container_* /tmp/ponto.*
		exit;
	else 
		escolha $OPCAO;
		if [ "$OPCAO" != 0 ]; then
			fim;
		fi
	fi
}

function menu_consulta() {

	while [ "$OPCAO" != "0" ]; do
		MENU="CONSULTA"
		banner;
		echo
		echo -e "\t+-------------------------------+"
		echo -e "\t| PONTO DE COLETA\t\t|"
		echo -e "\t+-------------------------------+"
		echo -e "\t> [1] - Listar pontos de coleta"
		echo -e "\t_________________________________"
		echo;echo
		echo -e "\t+-------------------------------+"
			echo -e "\t| CONTAINERS\t\t\t|"
		echo -e "\t+-------------------------------+"
		echo -e "\t> [2] - Listar TODOS"
		echo -e "\t> [3] - Listar DISPONIVEIS"
		echo -e "\t> [4] - Listar ALOCADOS"
		echo -e "\t> [5] - Listar COLETAR"
		echo -e "\t_________________________________"
		echo;echo
		echo -e "\t<----------------------------------<"
		echo -e "\t< [0] - Retornar ao Menu PRINCIPAL <"
		echo -e "\t<----------------------------------<"
		echo -e "\t____________________________________"
		echo -e "\t[Shift+PgUp] - Subir Tela"
		echo -e "\t[Shift+PgDn] - Descer Tela"
		opcao;
		if [ "$OPCAO" == 0 ]; then
		    return;
		else
		    escolha "consulta $OPCAO";
		    fim;
		fi
	done

}

function menu_registro() {

	while [ "$OPCAO" != "0" ]; do
		MENU="REGISTRO"
		banner;
		echo
		echo -e "\t+-----------------------+"
		echo -e "\t| CADASTRAR\t\t|"
		echo -e "\t+-----------------------+"
		echo -e "\t> [1] - Ponto de Coleta"
		echo -e "\t> [2] - Container"
		echo -e "\t_________________________"
		echo;echo
		echo -e "\t+-----------------------+"
		echo -e "\t| DELETAR\t\t|"
		echo -e "\t+-----------------------+"
		echo -e "\t> [3] - Ponto de Coleta"
		echo -e "\t> [4] - Container"
		echo -e "\t_________________________"
		echo;echo
		echo -e "\t+-----------------------+"
		echo -e "\t| ATUALIZAR\t\t|"
		echo -e "\t+-----------------------+"
		echo -e "\t> [5] - Ponto de Coleta"
		echo -e "\t> [6] - Container"
		echo -e "\t_________________________"
		echo;echo
		echo -e "\t------------------------------------"
		echo -e "\t< [0] - Retornar ao Menu PRINCIPAL"
		echo -e "\t____________________________________"
		echo -e "\t[Shift+PgUp] - Subir Tela"
		echo -e "\t[Shift+PgDn] - Descer Tela"
		opcao;
		if [ "$OPCAO" == 0 ]; then
		    return;
		else
		    escolha "registro $OPCAO";
	    	    if [ "$OPCAO" != 0 ]; then
			fim;
		    fi
		fi
	done

}
function cadastrar_ponto_coleta() {

	MENU="REGISTRO"
	banner;
	unset ENDERECO RESPONSAVEL TELEFONE
	echo
	echo -e "\t+-----------------------+"
	echo -e "\t| PONTO DE COLETA\t|"
	echo -e "\t+-----------------------+"
	echo
	echo -en "\t> Endereco: "
	read ENDERECO
	echo -en "\t> Responsavel: "
	read RESPONSAVEL
	echo -en "\t> Telefone: "
	read TELEFONE
	echo;echo
	echo -e "\t+-----------------------+"
	echo -e "\t| CONFIRMAR REGISTRO\t|"
	echo -e "\t+-----------------------+"
	echo
	echo -e "\t+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+"
	echo -e "\t| Endereco: $ENDERECO"
	echo -e "\t| Responsavel: $RESPONSAVEL"
	echo -e "\t| Telefone: $TELEFONE"
	echo -e "\t+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+"
	echo -e "\t___________________________"
	echo -e "\t[Shift+PgUp] - Subir Tela"
	echo -e "\t[Shift+PgDn] - Descer Tela"
	confirma;
	if [ "$CONFIRMA" = "n" ] || [ "$CONFIRMA" = "N" ]; then
		return;
	else
		escolha "cadastro 1";
	fi
}

function cadastrar_container() {

	MENU="REGISTRO"
	banner;
	echo
	echo -e "\t+-----------------------+"
	echo -e "\t| CONTAINER\t\t|"
	echo -e "\t+-----------------------+"
	echo
	echo -en "\t> Codigo: "
	read CODIGO
	echo;echo
	echo -e "\t+-----------------------+"
	echo -e "\t| CONFIRMAR REGISTRO\t|"
	echo -e "\t+-----------------------+"
	echo -e "\t| Codigo: $CODIGO"
	echo -e "\t| Status: DISPONIVEL"
	echo -e "\t_________________________"
	echo -e "\t[Shift+PgUp] - Subir Tela"
	echo -e "\t[Shift+PgDn] - Descer Tela"
	confirma;
	if [ "$CONFIRMA" = "n" ] || [ "$CONFIRMA" = "N" ]; then
		return;
	else
		escolha "cadastro 2";
	fi
}

function deletar_registro() {

	unset ID
	MENU="DELETAR"
	banner;
	while [ -z $ID ]; do
		echo
		echo -e "\t+-----------------------+"
		if [ "$TIPO" == PONTO ]; then
			echo -e "\t| DELETAR $TIPO\t\t|"
		else
			echo -e "\t| DELETAR $TIPO\t|"
		fi
		echo -e "\t+-----------------------+"
		echo
		echo -en "\t> ID: "
		read ID
		echo
		case "$ID" in
			*[0-9]*) ;;
			*) echo "[!] Codigo invalido!"; unset CODIGO; return;;
		esac
	echo;echo
	done
	if [ "$TIPO" == "PONTO" ] ; then
		TABLE=pontos_coleta
		query "SELECT * FROM pontos_coleta WHERE id = $ID \G;";
	else
		if [ "$TIPO" == "CONTAINER" ]; then	
			query "SELECT * FROM containers WHERE id = $ID \G;";
			TABLE=containers
		fi
	fi
	echo -e "[Shift+PgUp] - Subir Tela"
	echo -e "[Shift+PgDn] - Descer Tela"
	confirma;
	if [ "$CONFIRMA" = "n" ] || [ "$CONFIRMA" = "N" ]; then
		return;
	else
		query "delete from $TABLE where id = $ID;" > /dev/null
	fi
}

function atualizar_registro() {

	unset ID
	MENU="ATUALIZAR"
	banner;
	while [ -z $ID ]; do
		echo
		echo -e "\t+-----------------------+"
		if [ "$TIPO" == PONTO ]; then
			echo -e "\t| ATUALIZAR $TIPO\t|"
		else
			echo -e "\t| ATUALIZAR $TIPO\t|"
		fi
		echo -e "\t+-----------------------+"
		echo
		echo -en "\t> ID $TIPO: "
		read ID
		echo
		case "$ID" in
			*[0-9]*) ;;
			*) echo "[!] ID invalido!"; unset ID; return;;
		esac
	done
	if [ "$TIPO" == "PONTO" ] ; then
		query "SELECT * FROM pontos_coleta WHERE id = $ID \G;" > /tmp/ponto_coleta_$ID;
		if ! grep . /tmp/ponto_coleta_$ID | grep -v CONSULTA > /dev/null; then
			echo "[!] Registro nao encontrado";
			return;
		else
			cat /tmp/ponto_coleta_$ID;
		fi
		echo -en "\t> Endereco: "
		read ENDERECO
		echo -en "\t> Responsavel: "
		read RESPONSAVEL
		echo -en "\t> Telefone: "
		read TELEFONE
		echo;echo
		echo -e "\t+-----------------------+"
		echo -e "\t| CONFIRMAR REGISTRO\t|"
		echo -e "\t+-----------------------+"
		echo
		echo -e "\t+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+"
		echo -e "\t| Endereco: $ENDERECO"
		echo -e "\t| Responsavel: $RESPONSAVEL"
		echo -e "\t| Telefone: $TELEFONE"
		echo -e "\t+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+"
		echo -e "\t___________________________"
		echo -e "\t[Shift+PgUp] - Subir Tela"
		echo -e "\t[Shift+PgDn] - Descer Tela"
		confirma;
		if [ "$CONFIRMA" = "n" ] || [ "$CONFIRMA" = "N" ]; then
			return;
		else
			escolha "cadastro 3";
		fi
	
		else
		if [ "$TIPO" == "CONTAINER" ]; then	
			query "SELECT * FROM containers WHERE id = $ID \G;" > /tmp/container_$ID;
			if ! grep . /tmp/container_$ID | grep -v CONSULTA > /dev/null; then
				echo "[!] Registro nao encontrado";
				return;
			else
				cat /tmp/container_$ID;
			fi
			ID_CONTAINER=$ID
			CODIGO=$(awk -F: '/codigo/ {print $2}' /tmp/container_$ID | sed 's/^ //g')
			STATUS_ATUAL=$(awk -F: '/status/ {print $2}' /tmp/container_$ID | sed 's/^ //g')
			echo -e "\t+-----------------------+"
			echo -e "\t| ATUALIZAR STATUS\t|"
			echo -e "\t+-----------------------+"
			echo -e "\t> [0] - DISPONIVEL"
			echo -e "\t> [1] - ALOCADO"
			echo -e "\t> [2] - COLETAR"
			echo -e "\t_________________________"
			echo
			status_container;
			verifica_container || return;
			echo;echo
			echo -e "\t+-------------------------------------------------------+"
			echo -e "\t| CONFIRMAR REGISTRO\t\t\t\t\t|"
			echo -e "\t+-------------------------------------------------------+"
			echo -e "\t| Codigo: $CODIGO"
			echo -e "\t| Status: $STATUS"
			if [ ! -z "$PONTO_COLETA" ]; then
				echo -e "\t| Endereco: $PONTO_COLETA"
				echo -e "\t| Responsavel: $PONTO_RESPONSAVEL"
				echo -e "\t| Telefone: $PONTO_TELEFONE"
			fi
			echo -e "\t_________________________________________________________"
			echo -e "\t[Shift+PgUp] - Subir Tela"
			echo -e "\t[Shift+PgDn] - Descer Tela"
			confirma;
			if [ "$CONFIRMA" = "n" ] || [ "$CONFIRMA" = "N" ]; then
				return;
			else
				if [ "$STATUS" == "DISPONIVEL" ]; then
					escolha "cadastro 4";
				fi
				if [ "$STATUS" == "ALOCADO" ]; then
					escolha "cadastro 5";
				fi
				if [ "$STATUS" == "COLETAR" ]; then
					escolha "cadastro 6";
				fi
			fi
		fi
	fi
}


function main() {

	while true; do
		menu_principal;
	done;
}

main;
