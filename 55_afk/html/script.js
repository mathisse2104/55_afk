const hud = document.getElementById("hud")
const zoneName = document.getElementById("zoneName")
const progressFill = document.getElementById("progressFill")
const timerText = document.getElementById("timer")
const afkDurationText = document.getElementById("afkDuration")

let countdownInterval = null
let rewardInterval = null
let afkDurationInterval = null
let afkStartTime = 0

function formatTime(seconds) {
  const hours = Math.floor(seconds / 3600)
  const mins = Math.floor((seconds % 3600) / 60)
  const secs = seconds % 60
  return `${String(hours).padStart(2, "0")}:${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`
}

function formatCountdown(seconds) {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`
}

window.addEventListener("message", (event) => {
  const data = event.data

  if (data.action === "showHUD") {
    hud.classList.remove("hidden")
    zoneName.textContent = data.zone || "-"
    progressFill.style.width = "0%"
    afkDurationText.textContent = "00:00:00"

    let countdown = data.activationTime || 10
    timerText.textContent = formatCountdown(countdown)

    if (countdownInterval) clearInterval(countdownInterval)
    countdownInterval = setInterval(() => {
      countdown--
      if (countdown >= 0) {
        timerText.textContent = formatCountdown(countdown)
      } else {
        clearInterval(countdownInterval)
      }
    }, 1000)
  }

  if (data.action === "hideHUD") {
    hud.classList.add("hidden")
    if (countdownInterval) clearInterval(countdownInterval)
    if (rewardInterval) clearInterval(rewardInterval)
    if (afkDurationInterval) clearInterval(afkDurationInterval)
  }

  if (data.action === "updateProgress") {
    progressFill.style.width = `${data.percent}%`
  }

  if (data.action === "afkActive") {
    progressFill.style.width = "100%"

    if (countdownInterval) clearInterval(countdownInterval)

    afkStartTime = 0
    if (afkDurationInterval) clearInterval(afkDurationInterval)
    afkDurationInterval = setInterval(() => {
      afkStartTime++
      afkDurationText.textContent = formatTime(afkStartTime)
    }, 1000)

    const rewardInterval_minutes = data.rewardInterval || 5
    const maxTime = rewardInterval_minutes * 60
    let rewardTime = maxTime

    timerText.textContent = formatCountdown(rewardTime)

    if (rewardInterval) clearInterval(rewardInterval)
    rewardInterval = setInterval(() => {
      rewardTime--
      timerText.textContent = formatCountdown(rewardTime)

      if (rewardTime <= 0) {
        rewardTime = maxTime
      }
    }, 1000)
  }

  if (data.action === "afkStopped") {
    progressFill.style.width = "0%"
    timerText.textContent = "00:00"
    afkDurationText.textContent = "00:00:00"
    if (countdownInterval) clearInterval(countdownInterval)
    if (rewardInterval) clearInterval(rewardInterval)
    if (afkDurationInterval) clearInterval(afkDurationInterval)
  }

  if (data.action === "rewardReceived") {
    progressFill.style.width = "100%"
    const rewardInterval_minutes = data.rewardInterval || 5
    const maxTime = rewardInterval_minutes * 60
    timerText.textContent = formatCountdown(maxTime)
  }
})
