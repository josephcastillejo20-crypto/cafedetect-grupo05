from django.db import models
from django.contrib.auth.models import User


class Analisis(models.Model):
    """Guarda cada clasificación realizada por un usuario."""
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='analisis',
        null=True,
        blank=True,
    )
    patologia = models.CharField(max_length=100)
    confianza = models.FloatField()
    recomendacion = models.TextField()
    fecha = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-fecha']

    def __str__(self):
        return f"{self.patologia} ({self.confianza:.1f}%) - {self.fecha:%d/%m/%Y}"
