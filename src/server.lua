-- Counter server

-- settings
pulse_pin = 1
min_pulsewidth_ms = 250
upload_rate_ms = 60 * 1000
counterfile = "water.counter"
unit = "litres"
unitsperpulse = 10

nodered_server = "sel-l-services01.selstam.nu"
nodered_port = 1880
nodered_url = "/water"

-- variables
led_pin = 7
counterinfile = 0
pulse_detected = 0
counter = 0
conn = nil

function pin1high(level)
    pulse_detected = 1
end

function upload()
    print("Uploading to server...")

    gpio.write(led_pin, gpio.LOW)

    if conn == nil then
        conn = net.createConnection(net.TCP, 0)
    end
    conn:on("receive", function(conn, pl) print(pl) end)
    conn:on("connection", function(conn)

    local units = (counter - counterinfile) * unitsperpulse

    conn:send("GET "..nodered_url.."?meter="..counter.."&"..unit.."="..units.." HTTP/1.1\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
        conn:close()
        print("Upload done")
        savetofile()
        gpio.write(led_pin, gpio.HIGH)
    end)

    conn:connect(nodered_port, nodered_server)
end

function savetofile()
    if counterinfile ~= counter then
        if file.open(counterfile, "w+") then
            file.write(counter)
            file.close()
            print("Saved counter")
            counterinfile = counter
        end
    end
end

function loadfromfile()
    if file.exists(counterfile) then
        print("Counter file exists, read it")
        if file.open(counterfile, "r") then
            counter = file.readline()
            print("Counter is "..counter)
            file.close()
            counterinfile = counter
        end
    end
end

function maintask()
    print("Counter is:"..counter)
    if not wifi.sta.getip() then
        print("Connecting to AP, Waiting...")
    else
        upload()
    end
end

function pulsetask()
    if pulse_detected == 1 then
        counter = counter + 1
        print("Counter: "..counter)
        pulse_detected = 0
    end
end

-- init
gpio.mode(led_pin, gpio.OUTPUT)
gpio.write(led_pin, gpio.HIGH)

gpio.mode(pulse_pin, gpio.INT)
gpio.trig(pulse_pin, "up", pin1high)
tmr.alarm(0, upload_rate_ms, 1, maintask);
tmr.alarm(1, min_pulsewidth_ms, 1, pulsetask);

loadfromfile();

print("Running main task")

maintask();
