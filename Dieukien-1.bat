set RACK_ENV=production puma config.ru -b tcp://0.0.0.0:3000 -t 4:32 RACK_ENV=%RACK_ENV%
