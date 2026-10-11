package com.devops.travel_agencya_pi;

import org.springframework.boot.SpringApplication;

public class TestTravelAgencyaPiApplication {

	public static void main(String[] args) {
		SpringApplication.from(TravelAgencyaPiApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
