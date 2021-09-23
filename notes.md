# Notes on the Fullstack Workday

## Fly Log Viewer for the web

### Fly Infrastructure Diagram

- ![](https://firebasestorage.googleapis.com/v0/b/firescript-577a2.appspot.com/o/imgs%2Fapp%2Fmarcel%2FwtIq1BXEKL.png?alt=media&token=797b0d27-73d8-484d-a6fb-44a8ca40fe78)
- [Figma Link](https://www.figma.com/file/eHAQnRhcCBx6UTnYzF8Vfe/Information-Architecture-Diagram-Community-Copy?node-id=0%3A1)


### Notes

- My notes for the log viewer project. A bit more concise and easier to read than my full notes. But those are, like last time, underneath.
- First and foremost, I'd focus on performance and ease of use of the app. The browser eventually needs to display a lot of text and DOM Nodes, and I want to make the user experience of viewing those logs as pleasant as possible.
- As discussed with the team, we currently have two sources of logs: historical logs stored in Elastic Search and live logs, coming in via NATS. I focussed on the latter as I feel that's mostly expected from UI-ex right now and that adding a query interface for historical data would probably be beyond the scope.
- I ran some tests with the [official NATS client for Elixir](https://hex.pm/packages/gnat), and the usage is pretty straightforward. It's not much different to message passing between processes and feels native to OTP.
- Via NATS subjects/topics, we make sure we get the right kind of messages.
- Rendering those messages is done in Phoenix LiveView using a combination of `temporary_assigns`, LiveComponents and the [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) to make sure we only render stuff visible in the viewport.
- I would pre-populate the LiveView with some historical data (currently from the REST API that flyctl is using, or ES client)
- The log messages coming from NATS actually contain the original log message format in the message body, so that needs to be parsed before being displayed. There are libraries for all kinds of log formats, but it's also easy to do with just Elixir.
- Every log entry is rendered as a table row, and I use different colors to separate cells and make sure errors and warnings get the proper attention.
- If the user scrolls or wants to focus her attention on a particular message or group of messages, I will stop the live stream as soon as the user scrolls the content away from the bottom of the window. As soon as the user scrolls back to the bottom, I would reactivate the live stream, but there's also a button to go back to live mode as well (the twitch chat does this well, but also, for example, the youtube player when you jump back in time during a live stream and click then again on the "live" button)
- The next thing I would look at is filters. I was initially keeping them out of scope of the project, but in my overly optimistic and naive mind, it's pretty easy to add. We add the log viewer to the UI of each app, so no need to filter for apps anymore (like flyctl can do). The only other filters I could then think of are regions and VMs. A click on each inside a log message would activate a filter and add a remove button for that filter to the top of the viewer.
    - ![](https://firebasestorage.googleapis.com/v0/b/firescript-577a2.appspot.com/o/imgs%2Fapp%2Fmarcel%2FR80AM593AK.png?alt=media&token=e455cbbd-674d-4872-a328-cafc93ed8cbd)
    - Click any of those to activate a region filter
- One consideration is that due to how I decided to render it with temporary_assigns, it would be difficult to filter out already rendered items, so the filter would only apply for future items of the stream.  I had a few thoughts of using some clever CSS magic to do the trick, but I would have to try out and see how well that plays with the Intersection Observer.
- As said before, I would focus on the performance and snappiness so that it is actually more delightful and easy to use than the logs in the shell. That would be my main goal.
- Afterward, I would tackle historical logs and see how I can seamlessly integrate everything.
- That's all I've got for now. Thank you for reading and giving me the opportunity to cook on this. I really has been fun!


### Community Announcement


### My personal, messy notes

- 16:06 the first task is an overview of the dev UX stack, that includes all the main parts of the stack
- 17:45 cool, done that let's move onto the logging viewer.
- 17:46 The logging viewer is for the new Phoenix UI, ui-ex. There's also an update on how to get to those looks. In the past that was just polling a REST endpoint

- ```javascript
 curl https://api.fly.io/api/v1/apps/small-frog-8170/logs -H "Authorization: Bearer IalmostCommitedThis"
```

- but now it's using a NATS stream. I heard but never looked at nats, so I'm watching a quick video on how it works and then look if there's an Elixir client.
- 17:58 OK so instead of polling for data we're using a pub/sub system
- 18:20 I think I have a pretty good grasp on nats now. Good stuff by fly, not only seems that to be a great technology that fits well into their philosophy (few moving parts, super fast, easy to use) but it was also a surprise for the day today that I need to figure out something new. If would be just any log viewer I could've prepared everything beforehand, so I'm glad I didn't. Good test..
- 18:43 I'm currently figuring out how all the messages arrive in my app. There are not only logs but also events and who knows what else in the future. The common thing to do seems to filter messages by subjects. (Sidenote: This whole thing can then power other parts of the UI as well)
- 19:01 We just talked about how we actually have two ways to get logs, live via streams and historical data by querying elastic search
- 19:03 [soundtrack](https://www.youtube.com/watch?v=V2OCXiubvr0)
- 19:04 I'd probably focus on the streaming logs right now. Those are probably more useful to have as standalone, or? I'm actually not sure right now, but I think historical logs open a whole new can of worms.. Also, live is certainly more exciting right now and a good use case for liveview.
- 19:08 A log viewer is basically a window what displays a ton of text. And a livestream adds more and more of that all the time, so we have to make sure the users browser doesn't explode. Also, that the user can scroll through already existing logs.
- 19:19 [Gnat](https://github.com/nats-io/nats.ex) is the officially supported elixir client and it's pretty easy to use: You connect to a server and an optional subject and then just listen for message, pretty much like message passing in Elixir processes. There's also a phoenix pubsub library for nats, but it hasn't been updated in ages. It could be a cool project though.
- 19:43 I know, no coding, but I needed a little feel for how that whole thing works, so I built a small client app ([LINK](https://github.com/marcelfahle/nats-playground)) and it's really just simple listening for messages, which we can pattern match on.
- 19:50 ok, so we have a bunch of message now and my main concern is now to keep this thing fast and snappy. Features we can add later. There are two things to this in my opinion:
    - All log messages that aren't in the viewport (aka the log window) should be hidden/not rendered. I know react has a couple of libraries like react-virtualized that render giant lists pretty fast, but we want to use LiveView so I will look at the [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) to come up with something similar
    - The second part are temporary assigns in LiveView that make sure I don't have all my logs in memory after I've rendered them. It's also a good way to populate with some initial logs on page load, which I can either pull from ES or the current REST API that flyctl currently uses.
- 20:04 The other thing I also want to add is to pause the stream when the user scrolls a bit up. When the user scrolls the viewer back to the bottom, the livestream can resume. The twitch chat works pretty similar and stays snappy over many hours. As a little info for the user I'd add a little overlay to the bottom of the window: "Updates paused. Click to resume", and on click scrolls back to the latest and resumes streaming.
- 20:23 [soundtrack](https://www.youtube.com/watch?v=uGEDSGCUkXk)
- 20:33 wrote a quick tldr and added my play code to GH. Also, coffee.
- 20:42 In terms of general rendering, I would render everything as a table, a row per log entry and with cells for timestamp, region, vm and message. The log level I'd express with CSS classes and color code it, and also color the individual cells a bit to make it more visually pleasing and easy to read
- 20:50 The message (in system logs, not events) is of course the full server log message (is that ECS??), so we would need to parse that as well. There are of course libraries to parse all kinds of log formats, as well as NimbleParsec we could use for that. Given the amount of text that might come through it'd be worth to benchmark
    - Interesting sidenote: flyctl logs shows both timestamps, the one from the request and the one of the log entry. I wonder if that's relevant..?
- 21:08 Aside from that "scroll to start/stop" the live stream, I could add a pause button, to have it a bit more obvious (I think scrolling is enough though)
- 21:15 I keep thinking about filters for region and instances. At first I didn't want to add it to the first version of the log viewer, but It's actually pretty easy to do. Just add a filter to the assigns and then filter the log entries based on that when we're parsing them anyway. The filters I would apply when I click a region or an app right in a log entry in the viewer. Once I click for example "cdg" or "fra" I'd add the filter as a clickable tag with an x-Button to the top of the viewer window and filter all incoming messages based on that.
- 21:21 Yeah, we need those filters, to have at least the same feature set as flyctl logs.
- 21:31 One downside and consideration is that we can't really filter already rendered messages using the temporary assigns method above, because we don't have these messages in state anymore. I have to think about this a bit more, if that's even relevant or somehow otherwise achievable.
- 21:34 [soundtrack](https://www.youtube.com/watch?v=HjkoYnffNXI)
- 21:35 I feel like I'm not asking enough questions and that I'm missing something
- 21:54 I keep also coming back to historical logs. I mean it would be super cool to query ES and have some kind of mini kibana, but I wouldn't use that in the first version, especially when I need to keep the scope manageable. And as I said above, this opens up a whole bunch of other problems to solve.
- 21:58 So ok, now we have a log viewer. How would I think this thing is successful? I would, of course monitor the general usage. Especially the time users spend on the viewer. Personally, I like the terminal for pretty much everything except viewing logs or a lot of data. The browser is good for that and I want to make the web experience at least as powerful as the terminal experience and then some. Scrolling and searching a life stream is just so much more convenient in my opinion.
- 22:03 One other thing that I can't stress enough is how important performance is to me. It'll take some experimenting to find the best experience and by doing that, I'm not married to the tech I planned to use. Sure I love LiveView and want to use it for everything, but if it turns out it's not the right hammer for that particular nail and that for example Svelte or React can do this better, I'll use one of those (doubt it though 😉 ). I think the payloads that go through LV can't be optimized much, so it comes down to the fastest DOM diffing.
- I think that's all I've got for now. 🥴

