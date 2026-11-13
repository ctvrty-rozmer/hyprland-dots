pragma Singleton
import Quickshell

Singleton {
    function norm(d) { return ((d % 360) + 360) % 360 }
    function sind(d) { return Math.sin(d * Math.PI / 180) }

    // angle of the Moon ahead of the Sun, in degrees (0 = new, 180 = full)
    function elongation(date) {
        const jd = date.getTime() / 86400000 + 2440587.5
        const T = (jd - 2451545.0) / 36525

        const Lm = 218.3164477 + 481267.88123421 * T      // Moon mean longitude
        const D  = 297.8501921 + 445267.1114034 * T       // mean elongation
        const M  = 357.5291092 + 35999.0502909 * T        // Sun mean anomaly
        const Mp = 134.9633964 + 477198.8675055 * T       // Moon mean anomaly
        const F  = 93.2720950 + 483202.0175233 * T        // argument of latitude

        // the thirteen largest perturbation terms (Meeus, ch. 47), in millionths of a degree
        const moon = Lm + (
            6288774 * sind(Mp) + 1274027 * sind(2 * D - Mp) + 658314 * sind(2 * D) +
            213618 * sind(2 * Mp) - 185116 * sind(M) - 114332 * sind(2 * F) +
            58793 * sind(2 * D - 2 * Mp) + 57066 * sind(2 * D - M - Mp) + 53322 * sind(2 * D + Mp) +
            45758 * sind(2 * D - M) - 40923 * sind(M - Mp) - 34720 * sind(D) - 30383 * sind(M + Mp)
        ) / 1e6

        const L0 = 280.46646 + 36000.76983 * T            // Sun mean longitude
        const C = (1.914602 - 0.004817 * T) * sind(M) + 0.019993 * sind(2 * M) + 0.000289 * sind(3 * M)
        return norm(moon - (L0 + C))
    }

    // 0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter
    function phase(date) { return elongation(date) / 360 }

    // fraction of the disc that's lit, 0 to 1
    function illumination(date) { return (1 - Math.cos(elongation(date) * Math.PI / 180)) / 2 }

    // the four main phases get a name only within about half a day of the exact moment
    function name(p) {
        const e = p * 360
        const near = t => Math.abs(((e - t + 540) % 360) - 180) < 6
        if (near(0)) return "new moon"
        if (near(90)) return "first quarter"
        if (near(180)) return "full moon"
        if (near(270)) return "last quarter"
        return e < 90 ? "waxing crescent" : e < 180 ? "waxing gibbous" : e < 270 ? "waning gibbous" : "waning crescent"
    }
}