package com.counselling.model;

public class AppointmentStats {
    private int total;
    private int completed;
    private int upcoming;
    private int cancelled;

    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }

    public int getCompleted() { return completed; }
    public void setCompleted(int completed) { this.completed = completed; }

    public int getUpcoming() { return upcoming; }
    public void setUpcoming(int upcoming) { this.upcoming = upcoming; }

    public int getCancelled() { return cancelled; }
    public void setCancelled(int cancelled) { this.cancelled = cancelled; }
}