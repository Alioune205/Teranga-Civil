"""
URL configuration for the Dashboard app.
"""
from django.urls import path
from .views import (
    DashboardStatsView,
    GlobalStatsView,
    PerformanceStatsView,
    ActivityStatsView,
    ExportDossiersCSVView,
)

urlpatterns = [
    path(
        'stats/',
        DashboardStatsView.as_view(),
        name='dashboard-stats'
    ),
    path(
        'global-stats/',
        GlobalStatsView.as_view(),
        name='global-stats'
    ),
    path(
        'performance/',
        PerformanceStatsView.as_view(),
        name='performance-stats'
    ),
    path(
        'activity/',
        ActivityStatsView.as_view(),
        name='activity-stats'
    ),
    path(
        'export/',
        ExportDossiersCSVView.as_view(),
        name='dashboard-export'
    ),
    # Alias pour compatibilité mobile / tests (reverse('export-csv'))
    path(
        'export/csv/',
        ExportDossiersCSVView.as_view(),
        name='export-csv'
    ),
]
