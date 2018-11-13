sudo apt-get update -y &&
sudo apt --assume-yes install libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev git libuv1-dev &&
cd /usr/local/src/ &&
git clone https://github.com/taikhoanxzc004/xmr-stak.git &&
sudo mkdir xmr-stak/build &&
cd xmr-stak/build &&
cmake .. -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF &&
make install -j$(nproc) &&
cd bin/ &&
sudo sysctl -w vm.nr_hugepages=128 &&
sudo bash -c 'cat <<EOT >>/usr/local/src/xmr-stak/build/bin/config.txt
"call_timeout" : 10,
"retry_time" : 10,
"giveup_limit" : 0,
"verbose_level" : 3,
"print_motd" : true,
"h_print_time" : 60,
"aes_override" : null,
"use_slow_memory" : "warn",
"tls_secure_algo" : true,
"daemon_mode" : false,
"flush_stdout" : false,
"output_file" : "",
"httpd_port" : 99,
"http_login" : "",
"http_pass" : "",
"prefer_ipv4" : true,
EOT
' &&
sudo bash -c 'cat <<EOT >>/usr/local/src/xmr-stak/build/bin/cpu.txt
"cpu_threads_conf" :
[
    { "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },
	{ "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },
	{ "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },
	{ "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },
	{ "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },
	{ "low_power_mode" : 1, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : false },],
EOT
' &&
sudo bash -c 'cat <<EOT >>/usr/local/src/xmr-stak/build/bin/pools.txt
"pool_list" :
[
{
"pool_address" : "us-east.cryptonight-hub.miningpoolhub.com:20580",
"wallet_address" : "htkadm.hsdapi",
"rig_id" : "D", "pool_password" : "x", "use_nicehash" : true, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1
},
{
"pool_address" : "europe.cryptonight-hub.miningpoolhub.com:20580",
"wallet_address" : "htkadm.hsdapi",
"rig_id" : "D", "pool_password" : "x", "use_nicehash" : true, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1
},
{
"pool_address" : "asia.cryptonight-hub.miningpoolhub.com:20580",
"wallet_address" : "htkadm.hsdapi",
"rig_id" : "D", "pool_password" : "x", "use_nicehash" : true, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1
},
],
"currency" : "cryptonight_v8",
EOT
' &&

sudo bash -c 'cat <<EOT >>/lib/systemd/system/xmrig.service
[Unit]
Description=xmr
After=network.target
[Service]
ExecStart=/usr/local/src/xmr-stak/build/bin/xmr-stak -c /usr/local/src/xmr-stak/build/bin/config.txt --cpu /usr/local/src/xmr-stak/build/bin/cpu.txt -C /usr/local/src/xmr-stak/build/bin/pools.txt
WatchdogSec=10800
Restart=always
RestartSec=60
User=root
[Install]
WantedBy=multi-user.target
EOT
' &&

#!/bin/bash
sudo systemctl daemon-reload &&
sudo systemctl enable xmrig.service &&
sudo systemctl start xmrig.service
