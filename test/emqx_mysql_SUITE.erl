%% Copyright (c) 2013-2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(emqx_mysql_SUITE).

-compile(export_all).

-define(PID, emqx_mysql).

-define(APP, ?PID).

-include_lib("emqx/include/emqx.hrl").

-include_lib("eunit/include/eunit.hrl").

-include_lib("common_test/include/ct.hrl").

%%setp1 init table
-define(DROP_TABLE, <<"DROP TABLE IF EXISTS mqtt_msg">>).

-define(CREATE_TABLE, <<"CREATE TABLE mqtt_msg ("
                            "   id int(11) unsigned NOT NULL AUTO_INCREMENT,"
                            "   mid varchar(255) DEFAULT NULL,"
                            "   qos int(11) DEFAULT NULL,"
                            "   topic varchar(255) DEFAULT NULL,"
                            "   payload text,"
                            "   time int(11) DEFAULT NULL,"
                            "   PRIMARY KEY (`id`)"
                            ") ENGINE=InnoDB DEFAULT CHARSET=utf8">>).


all() ->
    [msg].

groups() ->
    [].

init_per_suite(Config) ->
    emqx_ct_helpers:start_apps([emqx, emqx_mysql], fun set_special_configs/1),
    Config.

end_per_suite(_Config) ->
    emqx_ct_helpers:stop_apps([emqx_mysql, emqx]).



msg() ->
    {ok, C} = emqx_client:start_link([{host, "localhost"},
                                      {client_id, <<"simpleClient">>},
                                      {username, <<"plain">>},
                                      {password, <<"plain">>}]),
    {ok, _} = emqx_client:connect(C),
    timer:sleep(1000),
    emqx_client:subscribe(C, <<"TopicA">>, qos2),
    timer:sleep(1000),
    emqx_client:publish(C, <<"TopicA">>, <<"Payload">>, qos2),
    timer:sleep(1000),
    receive
        {publish, #{payload := Payload}} ->
            ?assertEqual(<<"Payload">>, Payload)
    after
        1000 ->
            ct:fail({receive_timeout, <<"Payload">>}),
            ok
    end,
    emqx_client:disconnect(C).

init_acl_() ->
    {ok, Pid} = ecpool_worker:client(gproc_pool:pick_worker({ecpool, ?PID})),
    ok = mysql:query(Pid, ?DROP_TABLE),
    ok = mysql:query(Pid, ?CREATE_TABLE).


comment_config(_) ->
    application:stop(?APP),
    application:start(?APP).

set_cmd(Key) ->
    emqx_cli_config:run(["config", "set", string:join(["mysql", Key], "."), "--app=emqx_mysql"]).

drop_table_(Tab) ->
    {ok, Pid} = ecpool_worker:client(gproc_pool:pick_worker({ecpool, ?PID})),
    ok = mysql:query(Pid, Tab).

reload(Config) when is_list(Config) ->
    ct:pal("~p: all configs before: ~p ", [?APP, application:get_all_env(?APP)]),
    ct:pal("~p: trying to reload config to: ~p ", [?APP, Config]),
    application:stop(?APP),
    [application:set_env(?APP, K, V) || {K, V} <- Config],
    ct:pal("~p: all configs after: ~p ", [?APP, application:get_all_env(?APP)]),
    application:start(?APP).

set_special_configs(emqx) ->
    application:set_env(emqx, allow_anonymous, true),
    application:set_env(emqx, enable_acl_cache, true);
    
set_special_configs(_App) ->
    ok.
