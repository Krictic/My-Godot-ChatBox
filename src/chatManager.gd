extends Control

# Variable for unique ID
var id = ""
# Variable for Nickname
var nick = ""

func _ready():
	get_tree().connect("connected_to_server", self, "entered_room")
	get_tree().connect("server_disconnected", self, "server_disconnected")

func entered_room():
	$Panel/chatBox.text += "Entered Room\n"

func server_disconnected():
	$Panel/chatBox.text += "Server has disconnected\n"

# Send messagt when Enter is pressed
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			send_message()

func send_message():
	var message = $Panel/chatInput.text
	rpc("receive_message", id, nick, message)
	$Panel/chatInput.text = ""
	
sync func receive_message(id, nick, message):
	$Panel/chatBox.text += str(nick) + " (" + str(id) + ") " + ": " + message + "\n"

# Bad implementation, I know, but this is the best I could come up with.
# The fact ever user besides the hsot has the same nick is bad
# But you can always change your nick.
func join_room():
	$nickname.text = "User" # Yes, this means every user has the same nick.
	nick = $nickname.text
	var ip = $ipAddr.text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, 2000)
	get_tree().set_network_peer(host)
	id = get_tree().get_network_unique_id()


func host_chat():
	$nickname.text = "Host"
	nick = $nickname.text
	var host = NetworkedMultiplayerENet.new()
	host.create_server(2000)
	get_tree().set_network_peer(host)
	id = get_tree().get_network_unique_id()

# The function bellow will keep an updated list of every user currently
# connected to the chat
sync func _process(delta):
	$userList.clear()
	print("fetch")
	var fetchList = []
	for i in get_tree().get_network_connected_peers():
		fetchList.append(i)
	for idn in fetchList:
		$userList.add_item(str(idn))
	
	$userList.add_item(str(id))
	
# Join button
func _on_Button_pressed():
	join_room()

# Host button
func _on_Button2_button_up():
	host_chat()
	
# Leave button
func _on_leaveBTN_button_up():
	get_tree().set_network_peer(null)

# Change nick button
func _on_subNick_button_up():
	nick = $nickname.text
