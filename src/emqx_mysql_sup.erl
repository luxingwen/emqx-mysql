-module(emqx_mysql_sup).

-include("emqx_mysql.hrl").

-export([start_link/0, init/1]).

start_link()->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([])->
	{ok, Server} = application:get_env(?APP, server),
    PoolSpec = ecpool:pool_spec(?APP, ?APP, emqx_mysql_cli, Server),
    {ok, {{one_for_one, 10, 100}, [PoolSpec]}}.