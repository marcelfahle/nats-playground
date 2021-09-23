# Nats Playground

Just me messing around with nats and Gnat

## Usage

Fire up iex

```elixir
alias Nats.Playtime

gnat = Playtime.init

# spawn a listener
spawned = spawn(Playtime, :listen, [])

# sub the listener to nats
{:ok, _sub} = Gnat.sub(gnat, spawned, "app")

# send message (obviously coming from somewhere else)
Gnat.pub(gnat, "app", ~s({"event":{"provider":"app"},"fly":{"app":{"instance":"ef1c67d5","name":"flyio-web"},"region":"iad"},"host":"3902","log":{"level":"info"},"message":"I, [2021-09-23T15:36:16.329652 #522]  INFO -- : [a690644f-30e4-4271-84f3-d7e7d46a55b6] Started POST \"/graphql\" for 2a09:8280:1::1:8c5 at 2021-09-23 15:36:16 +0000","timestamp":"2021-09-23T15:36:16.329971992Z"}))

```
