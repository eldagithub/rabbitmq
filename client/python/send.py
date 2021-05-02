import pika, os

url = os.environ.get("CLOUDAMQP_URL", "amqp://guest:guest@localhost:5672/")
params = pika.URLParameters(url)
connection = pika.BlockingConnection(params)
channel.exchange_declare('test_exchange')
channel.queue_declare(queue="test_queue")
channel.queue_bind("test_queue", "test_exchange", "tests")
channel.basic_publish(exchange="test_exchange",
                            routing_key="tests",
                            body="Hello CloudAMQP!")
channel.close()
connection.close()

