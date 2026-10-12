package com.devops.travel_agencya_pi;

import org.springframework.boot.SpringApplication;

public class TestTravelAgencyApiApplication {

	public static void main(String[] args) {
		SpringApplication.from(TravelAgencyApiApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
