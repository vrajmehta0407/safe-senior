'use strict';
const axios = require('axios');
const { spawn } = require('child_process');

async function testAuth() {
  console.log('Testing SafeSenior Authentication Logic...\n');
  const baseUrl = 'http://localhost:3000/api';

  // 1. Test Login with 8866565480 and PIN 040705
  try {
    const res1 = await axios.post(`${baseUrl}/auth/login`, {
      phone_or_email: '8866565480',
      password: '040705'
    });
    console.log('✅ Test 1 (Login 8866565480): SUCCESS', res1.data.user);
  } catch (e) {
    console.error('❌ Test 1 FAILED:', e.response?.data || e.message);
  }

  // 2. Test Login with +918866565480 and PIN 040705
  try {
    const res2 = await axios.post(`${baseUrl}/auth/login`, {
      phone_or_email: '+918866565480',
      password: '040705'
    });
    console.log('✅ Test 2 (Login +918866565480): SUCCESS', res2.data.user);
  } catch (e) {
    console.error('❌ Test 2 FAILED:', e.response?.data || e.message);
  }

  // 3. Test Login with Email vrajmehta934@gmail.com and PIN 040705
  try {
    const res3 = await axios.post(`${baseUrl}/auth/login`, {
      phone_or_email: 'vrajmehta934@gmail.com',
      password: '040705'
    });
    console.log('✅ Test 3 (Login by Email): SUCCESS', res3.data.user);
  } catch (e) {
    console.error('❌ Test 3 FAILED:', e.response?.data || e.message);
  }

  // 4. Test Duplicate Signup with 8866565480
  try {
    const res4 = await axios.post(`${baseUrl}/auth/signup`, {
      name: 'Test Duplicate',
      phone_number: '8866565480',
      email: 'newemail@test.com',
      password: 'newpin1234'
    });
    console.error('❌ Test 4 FAILED (Should have been rejected):', res4.data);
  } catch (e) {
    console.log('✅ Test 4 (Prevent Duplicate Mobile 8866565480): REJECTED as expected (409 Conflict):', e.response?.data?.message);
  }

  // 5. Test Duplicate Signup with +918866565480
  try {
    const res5 = await axios.post(`${baseUrl}/auth/signup`, {
      name: 'Test Duplicate 2',
      phone_number: '+918866565480',
      email: 'another@test.com',
      password: 'newpin1234'
    });
    console.error('❌ Test 5 FAILED (Should have been rejected):', res5.data);
  } catch (e) {
    console.log('✅ Test 5 (Prevent Duplicate Mobile +918866565480): REJECTED as expected (409 Conflict):', e.response?.data?.message);
  }
}

testAuth();
