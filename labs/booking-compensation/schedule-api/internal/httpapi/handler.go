package httpapi

import (
	"context"
	"net/http"
	"time"

	"example.com/schedule-api/internal/schedule"
)

type handler struct{ service *schedule.Service }

func NewHandler(service *schedule.Service) http.Handler {
	h := handler{service: service}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", h.health)
	mux.HandleFunc("POST /appointments", h.create)
	mux.HandleFunc("POST /internal/appointments", h.create)
	mux.HandleFunc("GET /appointments/{id}", h.get)
	mux.HandleFunc("DELETE /internal/appointments/{id}", h.cancelInternal)
	mux.HandleFunc("POST /internal/appointments/{id}/cancel", h.cancelInternal)
	mux.HandleFunc("POST /internal/appointments/{id}/restore", h.restore)
	mux.HandleFunc("POST /appointments/{id}/cancel", h.cancelPublic)
	mux.HandleFunc("POST /appointments/{id}/complete", h.complete)
	mux.HandleFunc("PATCH /appointments/{id}", h.reschedule)
	return mux
}
func (h handler) health(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), time.Second)
	defer cancel()
	if h.service.Ready(ctx) != nil {
		jsonReply(w, 503, map[string]string{"status": "unavailable"})
		return
	}
	jsonReply(w, 200, map[string]string{"service": "schedule-api"})
}
func respond(w http.ResponseWriter, status int, value any, err error) {
	if err != nil {
		writeError(w, err)
		return
	}
	jsonReply(w, status, value)
}
func (h handler) create(w http.ResponseWriter, r *http.Request) {
	var v schedule.Appointment
	if !readJSON(w, r, &v) {
		return
	}
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Create(ctx, v)
	respond(w, 201, value, err)
}
func (h handler) get(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Get(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) cancelInternal(w http.ResponseWriter, r *http.Request) { h.cancel(w, r, false) }
func (h handler) cancelPublic(w http.ResponseWriter, r *http.Request)   { h.cancel(w, r, true) }
func (h handler) cancel(w http.ResponseWriter, r *http.Request, publish bool) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Cancel(ctx, r.PathValue("id"), publish)
	respond(w, 200, value, err)
}
func (h handler) restore(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Restore(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) complete(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Complete(ctx, r.PathValue("id"))
	respond(w, 200, value, err)
}
func (h handler) reschedule(w http.ResponseWriter, r *http.Request) {
	var v schedule.Interval
	if !readJSON(w, r, &v) {
		return
	}
	ctx, cancel := requestContext(r)
	defer cancel()
	value, err := h.service.Reschedule(ctx, r.PathValue("id"), v)
	respond(w, 200, value, err)
}
