# Charlie Cafe - Add a Debug / Error Logger to Employee Portal

Many production systems add a client-side error monitor inside the portal itself so users (or developers) can see problems without opening Chrome DevTools.

You can build a simple in-page error logger that tracks:

✔ JavaScript runtime errors

✔ Failed API calls

✔ Cognito token exchange failures

✔ Portal data loading issues

And show them in a floating notification log box.

This will work perfectly with your Amazon Cognito + AWS Lambda + Amazon API Gateway backend architecture.

### Add a Debug / Error Logger to Employee Portal

Add this just before </body> in employee-portal.html.

It will create a floating error box on the page.

```
<!-- ======================================================
🔎 CHARLIE DEBUG LOGGER
Shows runtime errors and API failures inside portal
====================================================== -->

<style>
#debugBox{
    position:fixed;
    bottom:10px;
    right:10px;
    width:350px;
    max-height:250px;
    overflow:auto;
    background:#000;
    color:#0f0;
    font-size:12px;
    padding:10px;
    border-radius:8px;
    z-index:9999;
    box-shadow:0 0 10px rgba(0,0,0,0.7);
}

#debugBox h6{
    color:#ffd166;
    font-size:13px;
    margin-bottom:5px;
}
</style>

<div id="debugBox">
<h6>Portal Debug Log</h6>
<div id="debugLogs"></div>
</div>

<script>
/* ======================================================
DEBUG LOGGER
====================================================== */

function logDebug(message,type="info"){

    const box = document.getElementById("debugLogs")

    const line = document.createElement("div")

    let color = "#0f0"

    if(type==="error") color="#ff4d4d"
    if(type==="warn") color="#ffaa00"

    line.style.color = color

    const time = new Date().toLocaleTimeString()

    line.textContent = "["+time+"] "+message

    box.prepend(line)
}

/* ======================================================
GLOBAL JS ERROR TRACKING
====================================================== */

window.onerror = function(msg,src,line,col,error){

    logDebug("JS ERROR: "+msg,"error")

}

/* ======================================================
PROMISE ERROR TRACKING
====================================================== */

window.addEventListener("unhandledrejection",function(event){

    logDebug("PROMISE ERROR: "+event.reason,"error")

})

/* ======================================================
FETCH API TRACKER
Logs all failed API calls
====================================================== */

const originalFetch = window.fetch

window.fetch = async function(...args){

    logDebug("API CALL: "+args[0])

    try{

        const response = await originalFetch(...args)

        if(!response.ok){

            logDebug("API ERROR "+response.status+" "+args[0],"error")

        }else{

            logDebug("API SUCCESS "+args[0])

        }

        return response

    }catch(err){

        logDebug("API FAILED "+err.message,"error")
        throw err

    }

}

/* ======================================================
COGNITO TOKEN DEBUG
====================================================== */

function logTokenExchange(code){

    logDebug("Cognito code received: "+code)

}

/* ======================================================
PORTAL DATA DEBUG
====================================================== */

function logPortalLoad(step){

    logDebug("Portal step: "+step)

}

</script>
```

### Example Logs You Will See

When things run you will see messages like:

```
[14:21:10] Cognito code received: 93f9a...
[14:21:10] API CALL: /exchange-token
[14:21:10] API SUCCESS /exchange-token
[14:21:11] Portal step: Loading employee profile
[14:21:11] API CALL: /employee/profile?employee_id=5
[14:21:11] API SUCCESS /employee/profile
```

If something fails:

```
[14:22:03] API CALL /exchange-token
[14:22:03] API ERROR 400 /exchange-token
[14:22:03] PROMISE ERROR invalid_grant
```

Or

```
[14:22:10] API CALL /employee/profile
[14:22:10] API FAILED Failed to fetch
```

This immediately tells you whether the problem is:

• Cognito login
• Lambda token exchange
• API Gateway
• RDS query

### Optional (Very Useful)

You can also add a toggle button to hide/show debug logs.

```
<button onclick="document.getElementById('debugBox').style.display='none'">
Hide Logs
</button>
```

### Why this will help you finish your project today

Instead of guessing, you will see exactly where the failure occurs:

```
Login → Token Exchange → API → RDS
```

Right now your failure is almost certainly happening at:

```
/exchange-token
```

This logger will confirm it instantly.

---
