import json
from channels.generic.websocket import WebsocketConsumer
from asgiref.sync import async_to_sync


class EventConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()
        async_to_sync(self.channel_layer.group_add)(
            "events",
            self.channel_name
        )

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            "events",
            self.channel_name
        )

    def receive(self, text_data):
        data = json.loads(text_data)
        # Handle incoming messages
        pass
