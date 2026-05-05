(function () {
    function createGradient(context, startColor, endColor) {
        const gradient = context.createLinearGradient(0, 0, 0, 320);
        gradient.addColorStop(0, startColor);
        gradient.addColorStop(1, endColor);
        return gradient;
    }

    async function renderDashboardCharts() {
        const temperatureCanvas = document.getElementById("temperatureChart");
        const humidityCanvas = document.getElementById("humidityChart");
        const activeCanvas = temperatureCanvas || humidityCanvas;

        if (!activeCanvas) {
            return;
        }

        const city = activeCanvas.dataset.city;
        if (!city) {
            return;
        }

        try {
            const response = await fetch(`/api/chart-data?city=${encodeURIComponent(city)}`);
            const payload = await response.json();

            if (!payload.has_data) {
                return;
            }

            if (temperatureCanvas) {
                const tempContext = temperatureCanvas.getContext("2d");
                new Chart(tempContext, {
                    type: "line",
                    data: {
                        labels: payload.labels,
                        datasets: [
                            {
                                label: "Temperature (C)",
                                data: payload.temperatures,
                                borderColor: "#29a8ff",
                                backgroundColor: createGradient(
                                    tempContext,
                                    "rgba(41, 168, 255, 0.35)",
                                    "rgba(41, 168, 255, 0.02)"
                                ),
                                fill: true,
                                tension: 0.35,
                                pointRadius: 3,
                                pointHoverRadius: 5,
                            },
                        ],
                    },
                    options: buildChartOptions(),
                });
            }

            if (humidityCanvas) {
                const humidityContext = humidityCanvas.getContext("2d");
                new Chart(humidityContext, {
                    type: "bar",
                    data: {
                        labels: payload.labels,
                        datasets: [
                            {
                                label: "Humidity (%)",
                                data: payload.humidities,
                                borderRadius: 10,
                                backgroundColor: payload.humidities.map(
                                    () => "rgba(45, 212, 191, 0.7)"
                                ),
                                borderColor: "#2dd4bf",
                                borderWidth: 1,
                            },
                        ],
                    },
                    options: buildChartOptions(),
                });
            }
        } catch (error) {
            console.error("Failed to render dashboard charts:", error);
        }
    }

    function renderForecastChart() {
        const forecastCanvas = document.getElementById("forecastChart");
        const chartData = window.weatherCharts && window.weatherCharts.forecast;

        if (!forecastCanvas || !chartData) {
            return;
        }

        const context = forecastCanvas.getContext("2d");

        new Chart(context, {
            type: "line",
            data: {
                labels: [...chartData.historyLabels, ...chartData.forecastLabels],
                datasets: [
                    {
                        label: "Historical Temp (C)",
                        data: [
                            ...chartData.historyTemps,
                            ...new Array(chartData.forecastLabels.length).fill(null),
                        ],
                        borderColor: "#29a8ff",
                        backgroundColor: createGradient(
                            context,
                            "rgba(41, 168, 255, 0.25)",
                            "rgba(41, 168, 255, 0.02)"
                        ),
                        fill: true,
                        tension: 0.3,
                        pointRadius: 3,
                    },
                    {
                        label: "Predicted Temp (C)",
                        data: [
                            ...new Array(chartData.historyLabels.length).fill(null),
                            ...chartData.forecastTemps,
                        ],
                        borderColor: "#2dd4bf",
                        backgroundColor: "transparent",
                        borderDash: [8, 6],
                        tension: 0.3,
                        pointRadius: 4,
                    },
                ],
            },
            options: buildChartOptions(),
        });
    }

    function buildChartOptions() {
        return {
            maintainAspectRatio: false,
            responsive: true,
            plugins: {
                legend: {
                    labels: {
                        color: "#edf6ff",
                    },
                },
            },
            scales: {
                x: {
                    ticks: {
                        color: "#90a4c7",
                        maxRotation: 45,
                        minRotation: 25,
                    },
                    grid: {
                        color: "rgba(144, 164, 199, 0.08)",
                    },
                },
                y: {
                    ticks: {
                        color: "#90a4c7",
                    },
                    grid: {
                        color: "rgba(144, 164, 199, 0.08)",
                    },
                },
            },
        };
    }

    function wireHistorySorting() {
        const table = document.getElementById("historyTable");
        if (!table) {
            return;
        }

        const headers = table.querySelectorAll("th[data-sort]");
        const tbody = table.querySelector("tbody");

        headers.forEach((header, index) => {
            header.addEventListener("click", () => {
                const type = header.dataset.sort;
                const rows = Array.from(tbody.querySelectorAll("tr"));
                const ascending = header.dataset.order !== "asc";

                rows.sort((rowA, rowB) => {
                    const valueA = rowA.children[index].textContent.trim();
                    const valueB = rowB.children[index].textContent.trim();

                    if (type === "number") {
                        return ascending
                            ? parseFloat(valueA) - parseFloat(valueB)
                            : parseFloat(valueB) - parseFloat(valueA);
                    }

                    return ascending
                        ? valueA.localeCompare(valueB)
                        : valueB.localeCompare(valueA);
                });

                headers.forEach((item) => {
                    item.dataset.order = "";
                });
                header.dataset.order = ascending ? "asc" : "desc";

                rows.forEach((row) => tbody.appendChild(row));
            });
        });
    }

    document.addEventListener("DOMContentLoaded", () => {
        renderDashboardCharts();
        renderForecastChart();
        wireHistorySorting();
    });
})();
