-module(emqx_mysql_cli).

-include("emqx_mysql.hrl").

-behaviour(ecpool_worker).

-export([connect/1, query/2]).

connect(Options) ->
	mysql:start_link(Options).


query(Sql, Params) ->
	ecpool:with_client(?APP, fun(C) -> mysql:query(C, Sql, Params) end).

