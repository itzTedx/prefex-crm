<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Ziina_gateway extends App_gateway
{
    public function __construct()
    {
        parent::__construct();

        // Gateway ID
        $this->setId('ziina');

        // Gateway name shown in Perfex
        $this->setName('Ziina');

        // Gateway settings
        $this->setSettings([
            [
                'name'      => 'api_key',
                'encrypted' => true,
                'label'     => 'Ziina API Access Token',
                'type'      => 'input',
            ],
            [
                'name'          => 'test_mode',
                'label'         => 'Test Mode',
                'type'          => 'yes_no',
                'default_value' => 1,
            ],
            [
                'name'          => 'currencies',
                'label'         => 'settings_paymentmethod_currencies',
                'default_value' => 'AED',
            ],
        ]);
    }

    public function process_payment($data)
    {
        // We will add the Ziina API payment code next
    }
}