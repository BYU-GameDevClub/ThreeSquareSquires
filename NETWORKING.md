# Basic Networking Explained

## Keys to Networking - Authority and RPCs

Lets say I have a bunch of characters on the screen and a giant button that says 'Move Player 1'. If you click the button, it calls a function - Move player 1, which is great and all; but it only calls on the local device
Here is the situation, and its results

| P1 CLICK | -Authority | P2 CLICK |          |
| :------: | :--------: | :------: | :------: |
| Player 1 |  Player 2  | Player 1 | Player 2 |
|  Moves   |  Nothing   | Nothing  |  Moves   |

Which works beautifully, but there is no networking happening, hitting the button only works locally, so lets introduce the ideas of _RPCs_. RPC or _Remote Protocol Call_ is a function that runs over the network, but we have a slight problem, who should be incharge of controling the player? Thus we have one more idea to introduce, Authority. Authority is how the computers determine who should run the function, in the above example, lets set Player 1 as the authority over themselves, by default authority belongs to the server, but it can be easily changed to whomever you want.

| P1 CLICK | -Authority | P2 CLICK |          |
| :------: | :--------: | :------: | :------: |
| Player 1 |  Player 2  | Player 1 | Player 2 |
| Nothing  |   Moves    | Nothing  | Nothing  |

Well thats, not super useful...... RPCs are weird, by default _ONLY_ the authority can call them, and they run everywhere but the authority, lets change up the example slightly to make it more clear:

| P1 Click | Auth |     | P2 Click | NoAuth |     |
| :------: | :--: | :-: | :------: | :----: | :-: |
|    P1    |  P2  | P3  |    P1    |   P2   | P3  |
|    🚫    |  ✅  | ✅  |    🚫    |   🚫   | 🚫  |

Now you can see that both Player 2 and 3 see the movement, but player 1 still doesn't, lets fix that, you can add a property to the RPC aptly named `'call_local'`, which makes it run locally like a normal function as well, lets make the change

| P1 Click | Auth |     | P2 Click | NoAuth |     |
| :------: | :--: | :-: | :------: | :----: | :-: |
|    P1    |  P2  | P3  |    P1    |   P2   | P3  |
|    ✅    |  ✅  | ✅  |    🚫    |   ✅   | 🚫  |

This is probably, what you want most of the time, but what if you want player 2 to be able to move it as well? Here is where the property `'any_peer'` comes in, this means the RPC is run additionally when its a peer, i.e. non-authority who runs it. With just `'any_peer'` we get:

| P1 Click | Auth |     | P2 Click | NoAuth |     |
| :------: | :--: | :-: | :------: | :----: | :-: |
|    P1    |  P2  | P3  |    P1    |   P2   | P3  |
|    🚫    |  ✅  | ✅  |    ✅    |   🚫   | ✅  |

Not perfect its missing the local calls, just like a regular rpc does, so lets add back in `'call_local'`.

| P1 Click | Auth |     | P2 Click | NoAuth |     |
| :------: | :--: | :-: | :------: | :----: | :-: |
|    P1    |  P2  | P3  |    P1    |   P2   | P3  |
|    ✅    |  ✅  | ✅  |    ✅    |   ✅   | ✅  |

And now the function runs on all machines, no matter who calls it, but you probably noticed, that when we did call local we allowed P2 to call move on only their screen when they clicked the button, we can fix this with a bit of fancy logic, but before we do that I should explain how Godot does RPCs

## The Code

Normal Function:

```GDScript
# definition
func my_func(args):
    code here

# call
my_func(args)
```

RPC Function:

```GDScript
# definition
@rpc()
func my_func(args):
    code here

# call
rpc('my_func',args)
```

If we wanted to add flags to the rpc like `'call_local'` we can do such

```GDScript
# definition
@rpc('call_local')
func my_func(args):
    code here

# call
rpc('my_func',args)
```

## Managing Authority

By default the authority of any Node/object is the server, or that client who started a server (known as the 'host'). If we want to change who manages an object we can do so with `set_multiplayer_authority(id)` or `nodeObj.set_multiplayer_authority(id)` where the `id` is the number assigned by the server when joining, the server always has `id = 1` while a client can be found as the argument to the callback function set during `multiplayer_peer.peer_connected.connect(callback_func)` more information can be found on the [docs](https://docs.godotengine.org/en/stable/classes/class_multiplayerapi.html#signals) or [Godot's tutorial](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html).

When a server is created a `multiplayer_peer` object is made and assigned as well, this keeps track of who is who and manages all the connections, additionally it allows usage of the MultiplayerAPI via the `multiplayer` property. When an rpc call is made you can check the source id of the caller by using `multiplayer.get_remote_sender_id()` or a list of all peer's ids with `multiplayer.get_peers()`. You check if the user is the server with `multiplayer.is_server()` or by seeing if `multiplayer.get_unique_id()` which returns the `id` of the owning authority is the server's id: _`1`_.

So going back to our example of rpc calls, we can made the rpc work only when called by the authority, but run on all machines by setting `'call_local'` and checking the id of `multiplayer.get_remote_sender_id()` is the id of the client with `multiplayer.get_remote_sender_id() == get_multiplayer_authority()`. Leaving us with something like:

```GDScript
# definition
@rpc('call_local')
func my_func(args):
    if multiplayer.get_remote_sender_id() != get_multiplayer_authority(): return
    code here

# call
rpc('my_func',args)
```

| P1 Click | Auth |     | P2 Click | NoAuth |     |
| :------: | :--: | :-: | :------: | :----: | :-: |
|    P1    |  P2  | P3  |    P1    |   P2   | P3  |
|    ✅    |  ✅  | ✅  |    🚫    |   🚫   | 🚫  |

## RPC Reliablity and Channels

Just as we can change _who_ gets and RPC call whe can change _how_ we send them the call, by default RPCs are sent as `'reliable'`, which means all the clients tell the server when they recieve the call, if they fail to respond the server will send the call again. This is very important for most function calls, but less important for something that is continuously updating, like the players position. In this case we can send the information with the flag `'unreliable'` which foregoes the need to double check that we have recieved the call, and as such is more performant. When we are sending lots of information we don't want the server to be backlogged with information, sometimes we do not care about their relative order to other calls, such as a chat message and gameplay, both need to be sent, but they are different things, in this situation we can take advantage of _channels_. Channels are also provided as part of the rpc flags,
