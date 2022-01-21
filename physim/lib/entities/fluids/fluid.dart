import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;

import 'package:physim/entities/entity.dart';
import 'package:physim/entities/fluids/fluid_particle.dart';
import 'package:vector_math/vector_math.dart';

const fluidMass = 2000000.0;
const fluidRadius = 7.0;
const fluidRadius2 = fluidRadius * fluidRadius;
const fluidViscosity = 20.0;
const gasConstant = 2222.0;
const restDensity = 0.0001;
final G = Vector2(0, 1.0);

final poly6 = 4.0 / (math.pi * math.pow(fluidRadius, 8));
final spikyGrad = -10.0 / (math.pi * math.pow(fluidRadius, 5));
final viscLap = 40.0 / (math.pi * math.pow(fluidRadius, 5));

class Fluid extends Entity {
  @override
  final int id;

  final List<FluidParticle> particles;

  Fluid({required this.id}) : particles = [];

  @override
  void update(double dt) {
    if (particles.length > 1) {
      computeDensityPressure();
      computeForces();
    }
    for (final p in particles) {
      var fGravity = G * fluidMass / (p.density == 0 ? 1 : p.density);
      p.force += fGravity;
      p.force *= 0.001;
      p.update(dt);
      // debugPrint(p.position.toString());
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      try {
        p.render(canvas);
      } catch (_) {}
    }
  }

  void addParticle(FluidParticle particle) {
    int c = particle.id;
    final r = Random();
    for (double x = particle.position.x;
        x < particle.position.x + 4 * fluidRadius;
        x += fluidRadius / 1.5) {
      for (double y = particle.position.y;
          y < particle.position.y + 4 * fluidRadius;
          y += fluidRadius / 1.5) {
        var i = r.nextInt(1);
        particles.add(FluidParticle(
            id: c++, position: Vector2(x.toDouble() + i, y.toDouble())));
      }
    }
  }

  void computeDensityPressure() {
    for (int i = 0; i < particles.length; i++) {
      particles[i].density = 0;
      final pi = particles[i];

      for (final pj in particles.where((k) => k.id != pi.id)) {
        var res = pj.position - pi.position;
        var r2 = res.length2;

        if (r2 < fluidRadius2) {
          particles[i].density +=
              fluidMass * poly6 * math.pow(fluidRadius2 - r2, 3);
        }
      }

      particles[i].pressure =
          gasConstant * math.max((pi.density - restDensity), 0);
    }
  }

  void computeForces() {
    for (int i = 0; i < particles.length; i++) {
      final pi = particles[i];

      var fPressure = Vector2.zero();
      var fViscosity = Vector2.zero();
      if (pi.density != 0) {
        for (final pj in particles.where((e) => e.id != pi.id)) {
          var res = pj.position - pi.position;
          var rad = (fluidRadius - res.normalize());

          if (rad < fluidRadius) {
            fPressure += (-res.normalized()) *
                fluidMass *
                (pi.pressure + pj.pressure) / // Pressure force contribution
                (2.0 * pj.density) *
                spikyGrad *
                (rad * rad * rad);

            fViscosity += (pj.velocity - pi.velocity) *
                fluidViscosity *
                fluidMass / // Viscosity force contribution
                pj.density *
                viscLap *
                rad;
          }
        }
      }

      particles[i].force = fPressure + fViscosity;
    }
  }
}
