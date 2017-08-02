%% Автор:
%% Дата: 15.02.2011

/*загружаются библиотеки*/
:-consult('../sgs_system.pl').
:-consult('../sgs_common.pl').
:-consult('../iec62056.pl').
:-consult('../server_62056.pl').
:-consult('../common_settings.pl').
:-consult('../database.pl').
:-consult('../server_62056_settings.pl').

:-consult('../lib/optparse.pl').

:-consult('server_satec_em_720_settings.pl').

server_satec_em_720:-server_62056.

