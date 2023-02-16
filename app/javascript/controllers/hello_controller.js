import { Controller } from "@hotwired/stimulus"
import { update } from "immutable"
import { ready } from "../services/rubyVM"

const canvas = document.getElementById("canvas")
const ctx = canvas.getContext("2d")
x = 250
y = 250

start = 0
step = Math.PI / 60

let loading

upe = function (timstamp) {
  start = start + step
  stop = start + 2 / 5 * Math.PI

  ctx.clearRect(0, 0, 500, 500)
  ctx.beginPath()
  ctx.arc(x, y, 20, start, stop, true)
  // ctx.fillStyle = "black"
  // ctx.fill()
  ctx.strokeStyle = "black"
  ctx.stroke()

  if (!ready()) {
    window.requestAnimationFrame(upe)
  }
}

window.requestAnimationFrame(upe)


export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
