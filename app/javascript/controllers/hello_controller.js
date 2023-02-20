import { Controller } from "@hotwired/stimulus"
import { update } from "immutable"
import { ready } from "../services/rubyVM"

const canvas = document.getElementById("canvas")
const ctx = canvas.getContext("2d")

x = 250
y = 250

start = 0
step = Math.PI / 60
upe = function (timstamp) {
  start = start + step
  stop = start + 3 / 5 * Math.PI + Math.sin(start)

  set_canvas_size()

  ctx.clearRect(0, 0, 500, 500)
  ctx.beginPath()
  ctx.arc(x, y, 20, start, stop, true)
  ctx.strokeStyle = "black"
  ctx.stroke()

  if (!ready()) {
    window.requestAnimationFrame(upe)
  }
}

set_canvas_size = function () {
  const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0)

  if (vw < 567) {
    let width = vw * 0.9;
    ctx.canvas.width = width;
    ctx.canvas.height = width;
    x = width / 2;
    y = width / 2;
  } else {
    ctx.canvas.width = 500;
    ctx.canvas.height = 500;
  }
}

window.requestAnimationFrame(upe)


export default class extends Controller {
  connect() {
    this.element.textContent = "Hello World!"
  }
}
