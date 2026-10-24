package httpapi

import (
	"context"
	"net/http"
	"time"

	"example.com/booking-api/internal/booking"
)

type handler struct{ service *booking.Service }

func NewHandler(service *booking.Service) http.Handler {
	h := handler{service: service}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", h.health)
	mux.HandleFunc("GET /users/{id}", h.user)
	mux.HandleFunc("GET /bookings/{id}", h.get)
	mux.HandleFunc("POST /bookings", h.create)
	mux.HandleFunc("POST /bookings/{id}/cancel", h.cancel)
	mux.HandleFunc("POST /internal/appointments/{id}/cancel", h.cancelFromSchedule)
	mux.HandleFunc("POST /internal/appointments/{id}/reschedule", h.rescheduleFromSchedule)
	mux.HandleFunc("POST /internal/appointments/{id}/complete", h.completeFromSchedule)
	return mux
}
func (h handler) health(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), time.Second)
	defer cancel()
	if h.service.Ready(ctx) != nil {
		jsonReply(w, 503, map[string]string{"status": "unavailable"})
		return
	}
	jsonReply(w, 200, map[string]string{"service": "booking-api"})
}
func respond(w http.ResponseWriter, status int, value any, err error) {
	if err != nil {
		writeError(w, err)
		return
	}
	jsonReply(w, status, value)
}
func (h handler) create(w http.ResponseWriter, r *http.Request) {
	var b booking.Booking
	if !readJSON(w, r, &b) {
		return
	}
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Create(ctx, b)
	respond(w, 201, value, err)
}
func (h handler) get(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Get(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) user(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.User(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) cancel(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Cancel(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) cancelFromSchedule(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.CancelFromSchedule(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) rescheduleFromSchedule(w http.ResponseWriter, r *http.Request) {
	var v booking.Interval
	if !readJSON(w, r, &v) {
		return
	}
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.RescheduleFromSchedule(ctx, r.PathValue("id"), v)
	respond(w, 200, value, err)
}
func (h handler) completeFromSchedule(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.CompleteFromSchedule(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
