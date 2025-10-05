# teenyHTTP

### A basic HTTP server written in precisely 100 lines of Go.

The install script has more lines of Bash than the actual `main.go` source file. Even this `README.md` file was written in more lines than teenyHTTP.

---

## Features:

- Manual overriding of paths
- No dependencies (unless you compile it yourself)
- Easy port selection

---

## Install & Setup:

### Install

1) `cd` into your working directory
    (replace `/your/path/to/your/files` with your path)
```shell
cd /your/path/to/your/files
```

2) Run the setup script
```shell
curl -fsSL https://raw.githubusercontent.com/supraboy981322/teenyHTTP/main/install-1.sh | sh
```
OR  
```shell
wget -fsSL https://raw.githubusercontent.com/supraboy981322/teenyHTTP/main/install-1.sh | sh
```

3) Follow the on-screen instructions


### Setup

1) Create a systemd service file
    (you may need `su` permissions, replace `nvim` with your prefered text editor, such as `nano` [`nano` is easier than `nvim`])
```shell
nvim /etc/systemd/system/teenyHTTP.service
```

2) Enter the following
    (replace `/your/working/directory/` with the directory of your configuration JSON files and files to serve, and `/your/executable/path` with the directory to the teenyHTTP executable)
> [!IMPORTANT]
> It is highly advised to use a user and group other than `root` for security purposes.
> (if you do, make sure the selected user and group have access to the `teenyHTTP` server and files)
```
[Unit]
Description=the teenyHTTP web server
After=syslog.target network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/
TimeoutStopSec=20
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```

3) Enable and start the service (you may need `su` permissions)
```shell
systemctl enable teenyHTTP.service
```
then
```shell
systemctl start teenyHTTP.service
```

4) Make sure the service was started (you may need `su` permissions)
```shell
systemctl status teenyHTTP.service
```

## Configuration

- ### Setting the port
  
    1) Open your `settings.json` file
        (replace `/your/working/dir` with the path to your working directory, and `nvim` with your prefered text editor)

       ```shell
        nvim /your/working/dir/settings.json
        ```
       
    3) Edit the line that has `"port":`
        (replace `1234` with the port you want teenyHTTP to use)
        ```
            "port": "1234",
        ```
        
- ### Changing the override setting

    1) Open your `settings.json` file
        (replace `/your/working/dir` with the path to your working directory, and `nvim` with your prefered text editor)
        ```shell
        nvim /your/working/dir/settings.json
        ```
        
    2) Edit the line that has `"override":`
        (replace `1234` with the port you want teenyHTTP to use)
        valid options are:  `true` and `false` (no quotations)
        ```
            "override": false,
        ```
        
- ### Configuring the override

    1) Open your `override.json` file
        (replace `/your/working/dir` with the path to your working directory, and `nvim` with your prefered text editor)
        ```shell
        nvim /your/working/dir/override.json
        ```
        
    2) Create a new line in the following format after the openning brace ( `{` )
        ```JSON
            "your-url/path": "your_file/path.html",
        ```
        your `override.json` file should look similar to this:
        ```JSON
        {
            "your-url/path": "your_file/path.html",
            "", "index.html"
        }
        ```
        
> [!WARNING]
> insure that you do not have a comma at the end of the last line before the ending brace
