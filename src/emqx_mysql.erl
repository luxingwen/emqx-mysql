-module(emqx_mysql).

-include("emqx_mysql.hrl").
-include_lib("emqx/include/emqx.hrl").

-export([load_hook/1, unload_hook/0, on_message_publish/2]).


load_hook(_Env) ->
	emqx:hook('message.publish', fun ?MODULE:on_message_publish/2, [#{}]).

unload_hook() ->
	emqx:unhook('message.publish', fun ?MODULE:on_message_publish/2).

on_message_publish(Message, _State) ->
	#message{id = Id, qos = Qos, topic = Topic, payload = Payload} = Message,
	emqx_mysql_cli:query(<<"INSERT INTO mqtt_msg(`mid`, `qos`, `topic`, `payload`, `time`) VALUE(?, ?, ?, ?, ?);">>, [emqx_guid:to_hexstr(Id), Qos, binary_to_list(Topic), binary_to_list(Payload), timestamp()]),
	{ok, Message}.

timestamp() ->
	{A,B,_C} = os:timestamp(),
	A*1000000+B.