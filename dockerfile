FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
	openssh-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# SSH PART #
RUN adduser stcom
RUN groupmod -g 100 users && usermod -u 1000 -g 100 stcom
RUN addgroup ssh
RUN usermod -aG ssh stcom
RUN chown -R stcom /app
RUN echo 'AllowGroups ssh' >> /etc/ssh/sshd_config
RUN echo 'cd /app' >> /home/stcom/.bashrc
RUN echo 'python3 test_run.py' >> /home/stcom/.bashrc
RUN echo 'exit' >> /home/stcom/.bashrc
RUN mkdir /var/run/sshd
# RUN chown -R stcom /app/Video
# Set root password for SSH access (change 'your_password' to your desired password)
RUN echo 'root:stcom' | chpasswd
RUN echo 'stcom:stcom' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]



# CMD ["python", "test_run.py"]
