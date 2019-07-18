-module(emqx_mysql).

-include("emqx_mysql.hrl").
-include_lib("emqx/include/emqx.hrl").

-export([load_hook/1, unload_hook/0, on_message_publish/2]).


load_hook(Env) ->
	emqx:hook('message.publish', fun ?MODULE:on_message_publish/2, [Env]).

unload_hook() ->
	emqx:unhook('message.publish', fun ?MODULE:on_message_publish/2).

on_message_publish(#message{from = emqx_sys} = Message, _State) ->
	{ok, Message};
on_message_publish(#message{flags = #{retain := true}} = Message, _State) ->
	#message{id = Id, qos = Qos, topic = Topic, payload = Payload, from = From} = Message,
	emqx_mysql_cli:query(<<"INSERT INTO mqtt_msg(`mid`, `client_id`, `topic`, `payload`, `time`) VALUE(?, ?, ?, ?, ?);">>, [emqx_guid:to_hexstr(Id), binary_to_list(From), binary_to_list(Topic), binary_to_list(Payload), timestamp()]),
	{ok, Message};

on_message_publish(Message, _State) ->
	{ok, Message}.

timestamp() ->
	{A,B,_C} = os:timestamp(),
	A*1000000+B.