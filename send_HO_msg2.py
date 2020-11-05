#!/usr/bin/python3

import asyncio
import sys
import hangups


CONVERSATION_ID = str(sys.argv[1])
MESSAGE = str(sys.argv[2])

REFRESH_TOKEN_PATH = '/home/CHANGE_ME/.cache/hangups/refresh_token.txt'


@asyncio.coroutine
def send_message(client):
    request = hangups.hangouts_pb2.SendChatMessageRequest(
        request_header=client.get_request_header(),
        event_request_header=hangups.hangouts_pb2.EventRequestHeader(
            conversation_id=hangups.hangouts_pb2.ConversationId(
                id=CONVERSATION_ID
            ),
            client_generated_id=client.get_client_generated_id(),
        ),
        message_content=hangups.hangouts_pb2.MessageContent(
            segment=[hangups.ChatMessageSegment(MESSAGE).serialize()],
        ),
    )
    yield from client.send_chat_message(request)
    yield from client.disconnect()


def main():
    cookies = hangups.auth.get_auth_stdin(REFRESH_TOKEN_PATH)
    client = hangups.Client(cookies)
    client.on_connect.add_observer(lambda: asyncio.async(send_message(client)))
    loop = asyncio.get_event_loop()
    loop.run_until_complete(client.connect())


if __name__ == '__main__':
    main()
