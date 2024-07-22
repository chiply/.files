// fundamental units
const millsecondsPerSecond = 1000;
const secondsPerMinute = 60;
const minutesPerHour = 60;
const degreesInCircle = 360;

// base config
const beatsPerHour = 28800;
const beatsPerMinute = beatsPerHour / minutesPerHour;
const beatsPerSecond = beatsPerMinute / secondsPerMinute;
const updateFrequency = millsecondsPerSecond / beatsPerSecond;
const rotationOffset = 90;
const hoursPerHourHandRevolution = 12;
const secondsPerSecondHandRevolution = 60;

// computed config
const minutesPerHourHandRevolution =
  minutesPerHour * hoursPerHourHandRevolution;
const degreesPerHourIndex = degreesInCircle / hoursPerHourHandRevolution;

function getTime() {
  const now = new Date();
  const milliseconds = now.getMilliseconds();
  const seconds = now.getSeconds();
  const mins = now.getMinutes();
  const hour = now.getHours();
  return { milliseconds, seconds, mins, hour };
}

function updateTime() {
  // get time
  const { milliseconds, seconds, mins, hour } = getTime();

  // compute degrees
  const secondsDegrees =
    ((seconds + milliseconds / millsecondsPerSecond) /
      secondsPerSecondHandRevolution) *
      degreesInCircle +
    rotationOffset;
  const minsDegrees =
    ((mins + seconds / secondsPerMinute) / minutesPerHour) * degreesInCircle +
    rotationOffset;
  const hourDegrees =
    ((hour + mins / minutesPerHour) / hoursPerHourHandRevolution) *
      degreesInCircle +
    rotationOffset;

  // set hand rotation
  document.querySelector(".second-hand").style.transform =
    `rotate(${secondsDegrees}deg)`;
  document.querySelector(".minute-hand").style.transform =
    `rotate(${minsDegrees}deg)`;
  document.querySelector(".hour-hand").style.transform =
    `rotate(${hourDegrees}deg)`;
}

function createIndexes() {
  const clock = document.querySelector(".clock");
  for (let i = 1; i <= 12; i++) {
    const index = document.createElement("div");
    index.textContent = i;
    index.classList.add("hour");
    index.classList.add(`hour${i}`);
    clock.appendChild(index);
  }
}

function setIndexes(radius) {
  // query indexes
  const indexes = document.querySelectorAll(".hour");
  const indexArray = Array.from(indexes);

  indexArray.forEach((index, _) => {
    // get the hour that the index represents
    const indexNumber = parseInt(index.classList[1].slice(4));
    hourIndexNumber = indexNumber === 12 ? 0 : indexNumber;

    // compute the angle in radians
    const angleInDegrees =
      hourIndexNumber * degreesPerHourIndex - rotationOffset;
    const angleInRadians = angleInDegrees * (Math.PI / 180);
    const xCoordinate = radius * Math.cos(angleInRadians);
    const yCoordinate = radius * Math.sin(angleInRadians);

    // set the position of the index
    index.style.top = `${yCoordinate + 50}%`;
    index.style.left = `${xCoordinate + 50}%`;
  });
}

createIndexes();
setIndexes(40);
updateTime(); // avoid delay on first render
setInterval(updateTime, updateFrequency);
