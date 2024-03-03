import os
import hashlib
import socket

def calculate_checksum(file_path):
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as f:
        buffer = f.read(65536)
        while len(buffer) > 0:
            hasher.update(buffer)
            buffer = f.read(65536)
    return hasher.hexdigest()


def main():
    port = os.environ.get('PORT', 8000)

    server_address = ('cp-server', int(port))

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(server_address)

    # Get the absolute path of the directory containing the script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, 'clientdata', 'received_file.txt')

    # Create clientdata directory if it doesn't exist
    clientdata_dir = os.path.join(script_dir, 'clientdata')
    if not os.path.exists(clientdata_dir):
        os.makedirs(clientdata_dir)

    # Receive file size
    file_size = int(client_socket.recv(1024).decode())
    client_socket.send(b'ACK')  # Send acknowledgment

    # Receive file contents
    received_data = b''
    while len(received_data) < file_size:
        received_data += client_socket.recv(1024)

    # Write received data to file
    with open(file_path, 'wb') as f:
        f.write(received_data)

    # Receive checksum
    received_checksum = client_socket.recv(1024).decode()

    client_socket.close()

    # Calculate checksum for received file
    calculated_checksum = calculate_checksum(file_path)

    if received_checksum == calculated_checksum:
        print("File received and checksum verified successfully.")
    else:
        print("Checksum verification failed.")

if __name__ == "__main__":
    main()
