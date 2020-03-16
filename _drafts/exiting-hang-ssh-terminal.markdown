---
title: How do you exit SSH connection when exit or Ctrl+D doesn't work?
layout: post
---

Recently I had an issue connecting to the remote server via SSH that for some reason, probably communication issues was
not responding to commands. 

Communication looked like this:

```bash
miro@mresetar:~$ ssh -l root 10.99.98.136
root@10.99.98.136's password:
Last login: Wed Feb 26 08:52:20 2020 from 192.168.126.233


exit



Connection to 10.99.98.136 closed.
```

Do you see that after exit SSH didn't exit the connection?
I've tried `Ctrl + D` too but without luck.

I might just close the terminal and open a new one, but sometimes, as this time, you want to keep history of 
executed commands. 
So what to do, of-course _Google-it_. Few links away is always helpful StackExchange with, in this case, Super User 
group.

Few links ahead was [How do I exit an SSH connection?](https://superuser.com/questions/467398/how-do-i-exit-an-ssh-connection)
link.

**Solution:** Simple. **Use keys `Enter~.`**. Depending on the keyboard layout for the `~` sign you might enter 2 keys.
For my keyboard this is `Alt Gr+1`. 

And that's it. After this key stroke sequence, message `Connection to 10.99.98.136 closed.` is printed.