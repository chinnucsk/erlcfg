%% 
%% Copyright (c) 2008-2010, Essien Ita Essien
%% All rights reserved.
%% 
%% Redistribution and use in source and binary forms, 
%% with or without modification, are permitted 
%% provided that the following conditions are met:
%%
%%    * Redistributions of source code must retain the 
%%      above copyright notice, this list of conditions 
%%      and the following disclaimer.
%%    * Redistributions in binary form must reproduce 
%%      the above copyright notice, this list of 
%%      conditions and the following disclaimer in the 
%%      documentation and/or other materials provided with 
%%      the distribution.
%%    * Neither the name "JsonEvents" nor the names of its 
%%      contributors may be used to endorse or promote 
%%      products derived from this software without 
%%      specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
%% WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
%% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
%% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
%% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
%% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
%% GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
%% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
%% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
%% THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
%% OF SUCH DAMAGE.
%% 

-module(node_addr).
-export([
        basename/1,
        parent/1,
        emancipate/1
    ]).

-export([
        join/1,
        split/1
    ]).

basename(NodeAddr) when is_atom(NodeAddr) ->
    {_Parent, Child} = emancipate(NodeAddr),
    Child.

parent(NodeAddr) when is_atom(NodeAddr) ->
    {Parent, _Child} = emancipate(NodeAddr),
    Parent.

join([]) ->
    '';
join(['', Single]) when is_atom(Single) ->
    Single;
join([H | _Rest]=NodeAddrList) when is_list(NodeAddrList), is_atom(H) ->
    AtomList2StrList = fun (Item) ->
            atom_to_list(Item)
    end,

    StrList = lists:map(AtomList2StrList, NodeAddrList),
    StrAddr = string:join(StrList, "."),
    list_to_atom(StrAddr).


split(NodeAddr) when is_atom(NodeAddr) ->
    StrAddr = atom_to_list(NodeAddr),
    StrList = string:tokens(StrAddr, "."),

    StrList2AtomList = fun (Item) -> 
            list_to_atom(Item)
    end,

    lists:map(StrList2AtomList, StrList).


emancipate('') ->
    invalid;

emancipate(NodeAddr) when is_atom(NodeAddr) ->
    List = split(NodeAddr),
    {ParentList, [Child]} = lists:split(length(List) - 1, List),
    {join(ParentList), Child}.
