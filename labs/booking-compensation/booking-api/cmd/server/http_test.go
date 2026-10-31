package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"sync/atomic"
	"testing"
	"time"
)

func TestLocalHTTPBypassesInheritedProxyAndRefusesRedirects(t *testing.T) {
	var proxyCalls, targetCalls, redirected atomic.Int32
	proxy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { proxyCalls.Add(1); io.WriteString(w, "proxy") }))
	defer proxy.Close()
	target := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		targetCalls.Add(1)
		if r.URL.Path == "/redirect" {
			http.Redirect(w, r, "/followed", http.StatusFound)
			return
		}
		if r.URL.Path == "/followed" {
			redirected.Add(1)
		}
		io.WriteString(w, "target")
	}))
	defer target.Close()
	inherited := http.DefaultTransport.(*http.Transport).Clone()
	proxyURL, _ := url.Parse(proxy.URL)
	inherited.Proxy = http.ProxyURL(proxyURL)
	old := http.DefaultTransport
	http.DefaultTransport = inherited
	t.Cleanup(func() { http.DefaultTransport = old; inherited.CloseIdleConnections() })
	// Positive control: the inherited default really routes this request through the proxy.
	response, err := (&http.Client{Timeout: time.Second}).Get(target.URL)
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	if proxyCalls.Load() != 1 || targetCalls.Load() != 0 {
		t.Fatal("proxy control did not exercise the inherited proxy")
	}
	c := localHTTPClient(time.Second)
	defer c.CloseIdleConnections()
	response, err = c.Get(target.URL)
	if err != nil {
		t.Fatal(err)
	}
	body, err := io.ReadAll(response.Body)
	response.Body.Close()
	if err != nil || string(body) != "target" || targetCalls.Load() != 1 || proxyCalls.Load() != 1 {
		t.Fatal("local request escaped through the proxy", err)
	}
	response, err = c.Get(target.URL + "/redirect")
	if err != nil {
		t.Fatal(err)
	}
	response.Body.Close()
	if response.StatusCode != http.StatusFound || redirected.Load() != 0 {
		t.Fatal("redirect followed outside the configured dependency")
	}
}
