extends Node

@rpc
func test_rpc(message: String) -> void:
    var peer_id = get_tree().multiplayer.get_unique_id()
    print("Peer ", peer_id, " received RPC with message: ", message)

func _ready() -> void:
    var multiplayer_peer: MultiplayerPeer

    if OS.get_cmdline_args().has("--server"):
        multiplayer_peer = ENetMultiplayerPeer.new()
        var err = multiplayer_peer.create_server(12345, 10)
        if err != OK:
            push_error("Server could not start!")
            return
        print("Server started with Peer ID: ", multiplayer_peer.get_unique_id())
    else:
        # Create an ENet client connecting to localhost on port 12345.
        multiplayer_peer = ENetMultiplayerPeer.new()
        var err = multiplayer_peer.create_client("127.0.0.1", 12345)
        if err != OK:
            push_error("Client could not start!")
            return
        print("Client started with Peer ID: ", multiplayer_peer.get_unique_id())

    get_tree().multiplayer.peer = multiplayer_peer

    yield(get_tree().create_timer(2.0), "timeout")
    
    if get_tree().multiplayer.is_server():
        print("Server: Sending RPC to all peers")
        rpc("test_rpc", "Hello from the server!")
    else:
        print("Client: Sending RPC to the server")
        rpc_id(1, "test_rpc", "Hello from the client!")
