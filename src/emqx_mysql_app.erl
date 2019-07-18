-module(emqx_mysql_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqx_mysql_sup:start_link(),
    emqx_mysql_cfg:register(),
    emqx_mysql:load_hook(application:get_all_env()),
    {ok, Sup}.

stop(_State) ->
	emqx_mysql_cfg:unregister(),
    emqx_mysql:unload_hook().
